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

def get_best_reciprocal_hits(db1_hash, db2_hash, evalue = nil, filtering = nil)

    # From https://doi.org/10.1093/bioinformatics/btm585
    # They recommend an E-value threshold of 1*10^-6
    # and that there is a query coverage of at least 50%.
    # Also, the best detection of orthologs as best reciprocal hits was obtained with soft filtering and a Smith-Waterman final alignment
    # (-F “m S” -s T), giving both the highest number of orthologs and the minimal error rates. However, using a Smith-Waterman final alignment
    # is computationally expensive, and almost the same results were achieved just by using soft filtering (-F “m S”), which is what I'll use.

    # Getting the additional arguments to pass to Bio::Blast.local
    arguments = ""
    arguments += "-e #{evalue} " if evalue # if evalue is not nil, adding the E-value argument
    arguments += "-F #{filtering} " if filtering # if filtering is not nil, adding the filtering argument

    # First blast: blasting the sequences from db1 (queries) against the database in db2 (database)
    blast_type_1 = determine_blast_type(type_query_seq = db1_hash[:db_type], type_db = db2_hash[:db_type])
    if arguments.empty? # no arguments passed
        factory = Bio::Blast.local(blast_type_1, db2_hash[:fasta_file_no_ext]) # database is db2
    else # some arguments passed
        factory = Bio::Blast.local(blast_type_1, db2_hash[:fasta_file_no_ext], arguments) # database is db2, additional arguments
    end

    # For each sequence (query) in db1:
    $stderr.puts "Blasting each sequence from #{db1_hash[:fasta_file_no_ext]} against the database #{db2_hash[:fasta_file_no_ext]}..."
    db1_ff = Bio::FlatFile.auto(db1_hash[:fasta_file])
    db1_ff.each_entry do |entry|
        report = factory.query(entry)
        next if report.hits.empty? # if no results, skip
        best_hit = report.hits.first
        next unless filter_by_coverage(query_start = best_hit.query_start,
                                         query_end = best_hit.query_end,
                                          query_length = best_hit.query_len, 
                                          threshold = 0.5) # True if coverage > 0.5, so the hit doesn't get skipped
        # If by now the entry hasn't been skipped, the best hit had more than 50% coverage
        # We do the search in the opposite direction


    end




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

def filter_by_coverage(query_start, query_end, query_length, threshold)
    coverage = (query_end.to_f - query_start.to_f)/query_length.to_f
    return coverage >= threshold
end

