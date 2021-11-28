require 'bio'

#
# <Description>
#
# @param [<Type>] fastafilename <description>
#
# @return [<Type>] <description>
#
def make_blast_db(fastafilename)
    begin
        # Finding out if it contains protein sequences or nucleotide sequences. It will only look at the first entry, so every entry should have the same type.
        fastaff = Bio::FlatFile.auto(fastafilename)
        seq_type = fastaff.next_entry.to_biosequence.guess # the type of the first entry, if nucleotide, guess returns Bio::Sequence::NA, and if protein, Bio::Sequence::AA
        database_type = 'nucl' if seq_type == Bio::Sequence::NA
        database_type = 'prot' if seq_type == Bio::Sequence::AA
        abort("Unknown type of database encountered by make_blast_db with the file #{fastafile}") unless seq_type == Bio::Sequence::NA || seq_type == Bio::Sequence::AA
        # Creating the database using the command makeblastdb, calling it from ruby
        filename_without_ext = fastafilename.split(/\.(?!\/)/).first # only splits by . if it isn't followed by / (https://stackoverflow.com/questions/12839645/ruby-string-split-with-regex)
        command = "makeblastdb -in #{fastafilename} -dbtype '#{database_type}' -out #{filename_without_ext}"
        puts "\nCommand: \n #{command}"
        # calling the command:
        system(command)
        return {fasta_file: fastafilename,
                fasta_file_no_ext: filename_without_ext,
                db_type: database_type}
             # returns a hash with the database name (with and without extension) and the database type
    rescue Errno::ENOENT => e # handling the missing file exception
        puts "ERROR: Can't find the file #{fastafilename}"
        $stderr.puts e.inspect
        abort
    rescue Exception => e # other possible exceptions
        puts "ERROR in make_blast_db"
        $stderr.puts e.inspect
        abort
    end
end


#
# <Description>
#
# @param [<Type>] db1_hash <description>
# @param [<Type>] db2_hash <description>
# @param [<Type>] evalue <description>
# @param [<Type>] filtering <description>
# @param [<Type>] coverage <description>
#
# @return [<Type>] <description>
#
def get_best_reciprocal_hits(db1_hash, db2_hash, evalue = nil, filtering = nil, coverage = nil)

    # Get the best hits from blasting every sequence of db1 against db2
    best_hits_q1_against_db2 = blast_db_against_db(db1_hash, db2_hash, 
        evalue = evalue, filtering = filtering, coverage = coverage)
    # Get the best hits from blasting every sequence of db2 against db1, including the previous results to avoid doing unnecessary blasts
    best_hits_q2_against_db1 = blast_db_against_db(db2_hash, db1_hash, 
        evalue = evalue, filtering = filtering, coverage = coverage, reverse_hash = best_hits_q1_against_db2)

    # Reciprocal hits:
    reciprocal_hits = {}
    # start with the second hash because we know its values are keys in the first hash
    best_hits_q2_against_db1.keys.each do |seq2|
        # getting the best hit from seq2
        seq1 = best_hits_q2_against_db1[seq2]
        # checking if the best hit's best hit is itself
        next unless seq2 == best_hits_q1_against_db2[seq1] # skipping if not
        # if we're here, success, we've found a best reciprocal hit
        reciprocal_hits[seq2] = seq1 # storing the results on the hash
    end
    return reciprocal_hits # returning the hash
end

#
# <Description>
#
# @param [<Type>] type_query_seq <description>
# @param [<Type>] type_db <description>
#
# @return [<Type>] <description>
#
def determine_blast_type(type_query_seq, type_db)
    # For this assignment only the last two are necessary
    return "blastp" if type_query_seq == "prot" && type_db == "prot" # search protein databases using a protein query
    return "blastn" if type_query_seq == "nucl" && type_db == "nucl" # search nucleotide databases using a nucleotide query
    return "blastx" if type_query_seq == "nucl" && type_db == "prot" # search protein databases using a translated nucleotide query
    return "tblastn" if type_query_seq == "prot" && type_db == "nucl" # search translated nucleotide databases using a protein query
    # if none of the above, the abort gets executed
    abort("This program doesn't support the combination of query type #{type_query_seq} and database type #{type_db}, it only accepts 'nucl' or 'prot'")
end

#
# <Description>
#
# @param [<Type>] query_start <description>
# @param [<Type>] query_end <description>
# @param [<Type>] query_length <description>
# @param [<Type>] threshold <description>
#
# @return [<Type>] <description>
#
def coverage_bigger_than_threshold?(query_start, query_end, query_length, threshold)
    coverage = (query_end.to_f - query_start.to_f)/query_length.to_f
    return coverage >= threshold
end

#
# <Description>
#
# @param [<Type>] evalue <description>
# @param [<Type>] filtering <description>
#
# @return [<Type>] <description>
#
def build_arguments_string(evalue = nil, filtering = nil)
    arguments = ""
    arguments += "-e #{evalue} " if evalue # if evalue is not nil, adding the E-value argument
    arguments += "-F #{filtering} " if filtering # if filtering is not nil, adding the filtering argument
    return arguments unless arguments.empty?
    return nil if arguments.empty?
end

#
# <Description>
#
# @param [<Type>] blast_type <description>
# @param [<Type>] database <description>
# @param [<Type>] arguments <description>
#
# @return [<Type>] <description>
#
def create_factory(blast_type, database, arguments = nil)
    if arguments.nil? || arguments.empty? # no arguments passed
        factory = Bio::Blast.local(blast_type, database)
    else # some arguments passed
        factory = Bio::Blast.local(blast_type, database, arguments) # additional arguments
    end
    return factory
end


#
# <Description>
#
# @param [<Type>] db1_hash <description>
# @param [<Type>] db2_hash <description>
# @param [<Type>] evalue <description>
# @param [<Type>] filtering <description>
# @param [<Type>] coverage <description>
# @param [<Type>] reverse_hash <description>
#
# @return [<Type>] <description>
#
def blast_db_against_db(db1_hash, db2_hash, evalue = nil, filtering = nil, coverage = nil, reverse_hash = nil)

    # Getting the additional arguments to pass to Bio::Blast.local
    arguments = build_arguments_string(evalue = evalue, filtering = filtering)
    # get the blast type:
    blast_type = determine_blast_type(type_query_seq = db1_hash[:db_type], type_db = db2_hash[:db_type])
    # build the appropriate blast factory:
    factory = create_factory(blast_type, db2_hash[:fasta_file_no_ext], arguments)

    # For each sequence (query) in db1:
    $stderr.puts "Blasting each sequence from #{db1_hash[:fasta_file_no_ext]} against the database #{db2_hash[:fasta_file_no_ext]}..."
    best_hits_q1_db2 = {} # hash to store the results
    db1_ff = Bio::FlatFile.auto(db1_hash[:fasta_file])
    db1_ff.each_entry do |entry|

        if reverse_hash # if there is a hash of the reverse search
            # skip this entry if it isn't a best hit of the reverse search
            next unless reverse_hash.value?(entry.definition.split("|").first.strip.to_sym)
        end

        report = factory.query(entry)
        next if report.hits.empty? # if no results, skip
        best_hit = report.hits.first
        # filtering by coverage
        unless coverage.nil?
            next unless coverage_bigger_than_threshold?(query_start = best_hit.query_start,
                                                        query_end = best_hit.query_end,
                                                        query_length = best_hit.query_len, 
                                                        threshold = coverage) # True if coverage > 0.5, so the hit doesn't get skipped
        end
        # If by now the entry hasn't been skipped, the best hit had more than 50% coverage
        # We do the search in the opposite direction
        seq1 = entry.definition.split("|").first.strip.to_sym # 'AT5G03780.1 | Symbols: TRFL10 | TRF-like 10 | chr5:999266-1000947 REVERSE LENGTH=1263' -> :AT5G03780.1
        seq2 = best_hit.definition.split("|").first.strip.to_sym
        best_hits_q1_db2[seq1] = seq2 # adding this to the hash
    end
return best_hits_q1_db2 # returns the hash with the hits of each entry of db1 against db2
end

#
# <Description>
#
# @param [<Type>] best_reciprocal_hits <description>
# @param [<Type>] output_name <description>
#
# @return [<Type>] <description>
#
def write_report(best_reciprocal_hits, output_name = "BRH_report.tsv")
    f = File.new(output_name, "w")
    best_reciprocal_hits.each do |seq1, seq2|
        f.write("#{seq1}\t#{seq2}\n")
    end
    f.close
end

