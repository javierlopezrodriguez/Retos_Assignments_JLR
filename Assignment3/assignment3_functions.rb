require 'bio'
require 'rest-client'

#
# Access an URL, function donated by Mark Wilkinson.
#
# @param [String] url URL
# @param [String] headers headers
# @param [String] user username, default ""
# @param [String] pass password, default ""
#
# @return [String, false] the contents of the URL, or false if an exception occured
#
def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
    response = RestClient::Request.execute({
        method: :get,
        url: url.to_s,
        user: user,
        password: pass,
        headers: headers})
    return response
    
    rescue RestClient::ExceptionWithResponse => e
        $stderr.puts e.inspect
        response = false
        return response 
    rescue RestClient::Exception => e
        $stderr.puts e.inspect
        response = false
        return response 
    rescue Exception => e # generic
        $stderr.puts e.inspect
        response = false
        return response 
end 

#
# Reads a file containing one gene id (in AGI locus code format) in each column
# and stores each id as a lowercase symbol on an array and returns it.
#
# @param [String] path Path of the txt file
#
# @return [Array<Symbol>, nil] The array of ids, or nil if an error occured
#
def read_gene_list(path)
    # for each gene in the file, stores the id as a lowercase symbol in gene_array (if it doesn't exist already)
    puts "Reading the gene list..."
    gene_array = []
    begin
        IO.foreach(path) do |gene|
            gene.strip!.downcase! # removing whitespace (if any) and converting the letters to lowercase
            gene_array |= [gene.to_sym] if gene =~ /at\wg\d\d\d\d\d/ # storing the gene id as a symbol if it matches the regexp
        end
        return gene_array # returns the gene_array
    rescue Errno::ENOENT => e # handling the missing file exception
        puts "ERROR: Can't find the file"
        $stderr.puts e.inspect
        return nil
    rescue Exception => e # other possible exceptions
        $stderr.puts e.inspect
        return nil
    end
end

#
# Given an array of gene ids, it gets the EMBL entry from ensemblgenomesgene,
# creates a Bio::EMBL object and stores it into a hash
#
# @param [Array<Symbol>] gene_array The array of gene ids
#
# @return [Hash<Symbol, Bio::EMBL>] The hash of Bio::EMBL objects for each EMBL entry
#
def get_embl(gene_array)
    unless gene_array && !gene_array.empty? # if there is nothing in the array, warning and exit the function, returning nil
        puts "WARNING: no genes in the gene array / no gene array"
        return nil
    end
    # else 
    puts "Getting the EMBL entries for each gene..."
    embl_hash = {} # Hash to store {gene_id => Bio::EMBL object}
    gene_array = [gene_array] unless gene_array.is_a?(Array) # converting it into an array if it isn't (if there's only one element)
    gene_array.each do |gene_id| # for each gene in the array
        # Getting an EMBL entry from dbfetch using the database ensemblgenomesgene (that accepts AGI locus codes)
        url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}&style=raw"
        response = fetch(url) # accessing the url
        if response
            entry = Bio::EMBL.new(response.body) # pass it the record as a string
            unless embl_hash.keys.include?(gene_id)
                embl_hash[gene_id] = entry # storing it in the hash
            else
                puts "WARNING: #{gene_id} already contains an entry in the embl_hash"
            end
        end
    end
    return embl_hash # returns the hash
end

#
# For every pair of positions in a position array, this function adds a new 'CTTCTT_direct_repeat' feature
# to a Bio::Sequence object, containing the position, sequence, strand, and an unique ID.
#
# @param [Bio::Sequence] biosequence The Bio::Sequence object, made from a Bio::EMBL object to be able to add features to it
# @param [Symbol] gene_id The id of the gene
# @param [Array<Array<Integer>>] positions_array An array of arrays, each subarray representing start and end positions, 1-indexed, of the feature in the gene
# @param [String] strand "+" for forward strand, "-" for the reverse strand
#
def create_and_add_features(biosequence, gene_id, positions_array, strand)
    
    positions_array.uniq.each_with_index do |position_pair, index|
        start_pos, end_pos = *position_pair
        # creating the position string
        if strand == +1 || strand == "+" || strand == "+1"
            position_string = "#{start_pos}..#{end_pos}"
            strand_label = "+"
        elsif strand == -1 || strand == "-" || strand == "-1"
            position_string = "complement(#{start_pos}..#{end_pos})"
            strand_label = "-"
        else
            puts "WARNING: For #{gene_id}, the strand parameter was #{strand}. It should be '+1' or '+' for the forward, and '-1' or '-' for the reverse"
            next
        end

        new_feature = Bio::Feature.new(feature = "CTTCTT_direct_repeat", position = position_string, 
                                        qualifiers = [Bio::Feature::Qualifier.new('sequence', 'CTTCTT'),
                                                        Bio::Feature::Qualifier.new('strand', strand_label),
                                                        Bio::Feature::Qualifier.new('ID', "#{gene_id.to_s.upcase}.CTTCTT_repeat.#{strand_label}.#{index + 1}")])
                                                        # id, for example: AT2G46340.CTTCTT_repeat.-.1
                                                        # that way I can use it afterwards for the GFF3 file
        biosequence.features << new_feature
    end
    # Don't need to return anything because the new feature is being added to the Bio::Sequence object
end

########################################
######## This comment is for myself to understand this:

##The sequence of the embl is always 5'3' and the exon can be on that one or on the complement one
######## https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=AT2G46340&style=raw
## that (embl) has the sequence 5'3', the exons are on the complement, so we would need the reverse complement of that
## if we translate this sequence as is, we dont get the proteins, because the exons are on the complement
## doing: get_embl([:AT2G46340])[:AT2G46340].seq gives me the sequence in the same orientation as above
## if I want to search for CTTCTT on the exons, I need to reverse complement the sequence or the query
## because the exons are on the complement strand

######## https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=AT2G46340&style=raw
## that (fasta) has the reverse complement already -> from here if we translate this we get the proteins
## here we would always look for CTTCTT because it is the correct strand (if we didn't want exons only)
########################################

#
# Given a hash of {Gene id => Bio::EMBL object}, it finds every 'CTTCTT' sequence in the exons of each gene,
# adds that feature to a new Bio::Sequence object containing all the previous information of the Bio::EMBL object,
# and returns the new hash of {Gene id => Bio::Sequence object}.
#
# @param [Hash<Symbol, Bio::EMBL>] embl_hash The hash of Bio::EMBL objects for each EMBL entry
#
# @return [Hash<Symbol, Bio::Sequence>] The new hash of Bio::Sequence objects, containing only the ids of those genes with 'CTTCTT' in any of their exons
#
def find_seq_in_exons(embl_hash)
    puts "Searching for CTTCTT in the entries..."
    new_embl_hash = {} # Hash to store {gene_id => Bio::EMBL object with the new features}

    embl_hash.each do |gene_id, bio_embl| # iterating over the hash

        bio_embl_as_biosequence = bio_embl.to_biosequence # turning the Bio::EMBL into Bio::Sequence so that I can add features
        embl_seq = bio_embl.seq # getting the dna sequence as Bio::Sequence::NA

        all_positions_forward = [] # store the positions of the feature CTTCTT on the forward strand
        all_positions_reverse = [] # store the positions of the feature CTTCTT on the reverse strand

        # iterating through each feature of the original bio_embl
        # not using bio_embl_as_biosequence here because I will be adding features 
        # and it's not good to manipulate an object while iterating through it
        bio_embl.features.each do |feature| 
            next unless feature.feature == "exon" # skip if the feature is not an exon
            next unless feature.assoc["note"].match(Regexp.new(gene_id.to_s, "i")) # skip if the exon is from another gene (because of overlapping or whatever)

            bio_location = feature.locations[0] # feature.locations is Bio::Locations, which is basically an array of Bio::Location objects
            exon_start_pos, exon_end_pos = bio_location.from, bio_location.to # 1-indexed, position of the exon with respect to the start of the gene

            exon_seq = embl_seq.subseq(exon_start_pos, exon_end_pos) # getting the sequence of the exon, 1-indexed, forward strand

            if bio_location.strand == +1 # the feature is on the current strand: we need to search for CTTCTT in the forward strand
                # To find the sequence, I'm using lookahead (?=) so that I can match overlapping expressions 
                # (https://stackoverflow.com/questions/41028602/find-overlapping-regexp-matches)
                # (https://stackoverflow.com/questions/5241653/ruby-regex-match-and-get-positions-of)
                start_f = exon_seq.enum_for(:scan, /(?=(cttctt))/i).map { Regexp.last_match.begin(0) + 1} # +1 so it is 1-indexed
                
                next if start_f.empty? # if there is no match, skip
                # if there is a match
                # Positions: 
                # pos is the position of the feature with respect to the exon
                # to get it with respect to the gene, we have to sum pos + exon_start_pos
                # everything is 1-indexed, so when summing two 1-indexed positions we have to substract 1.
                positions_f = start_f.map {|pos| [pos + exon_start_pos - 1, pos + exon_start_pos -1 + 5]} unless start_f.empty? # 1-indexed
                all_positions_forward |= positions_f # include the [start_pos, end_pos] pairs that aren't included already

            elsif bio_location.strand == -1 # the feature is on the complement strand: we need to search for the reverse complement, AAGAAG, in the forward strand
                # To find the sequence, I'm using lookahead (?=) so that I can match overlapping expressions 
                # (https://stackoverflow.com/questions/41028602/find-overlapping-regexp-matches)
                # (https://stackoverflow.com/questions/5241653/ruby-regex-match-and-get-positions-of)
                start_r = exon_seq.enum_for(:scan, /(?=(aagaag))/i).map { Regexp.last_match.begin(0) + 1} # 1-indexed

                next if start_r.empty? # if there is no match, skip
                # if there is a match
                # Positions: 
                # pos is the position of the feature with respect to the exon
                # to get it with respect to the gene, we have to sum pos + exon_start_pos
                # everything is 1-indexed, so when summing two 1-indexed positions we have to substract 1.
                positions_r = start_r.map {|pos| [pos + exon_start_pos - 1, pos + exon_start_pos -1 + 5]} unless start_r.empty? # 1-indexed
                all_positions_reverse |= positions_r # include the [start_pos, end_pos] pairs that aren't included already
            else
                puts "WARNING: no strand"
                next # skip
            end
        end
        # once every feature has been scanned for that Bio::EMBL object, we add the new CTTCTT features
        create_and_add_features(bio_embl_as_biosequence, gene_id, all_positions_forward, "+")
        create_and_add_features(bio_embl_as_biosequence, gene_id, all_positions_reverse, "-")
        # adding the biosequence object to the new hash unless no new features were added
        unless all_positions_forward.empty? && all_positions_reverse.empty? 
            new_embl_hash[gene_id] = bio_embl_as_biosequence unless new_embl_hash.keys.include?(gene_id)
        end
    end
    return new_embl_hash # return the new embl hash
end


#
# Writes a GFF3 file with all of the 'CTTCTT_direct_repeat' features, using the start of the gene as the coordinate origin.
#
# @param [Hash<Symbol, Bio::Sequence>] new_embl_hash The hash of Bio::Sequence objects, containing the 'CTTCTT_direct_repeat' features
# @param [String] filename The name of the output file
#
def write_gff3_local(new_embl_hash, filename = "CTTCTT_GFF3_gene.gff")
    write_gff3(new_embl_hash, mode = "local", filename = filename)
end

#
# Writes a GFF3 file with all of the 'CTTCTT_direct_repeat' features, using the start of the chromosome as the coordinate origin.
#
# @param [Hash<Symbol, Bio::Sequence>] new_embl_hash The hash of Bio::Sequence objects, containing the 'CTTCTT_direct_repeat' features
# @param [String] filename The name of the output file
#
def write_gff3_global(new_embl_hash, filename = "CTTCTT_GFF3_chromosome.gff")
    write_gff3(new_embl_hash, mode = "global", filename = filename)
end


#
# Writes a GFF3 file with all of the 'CTTCTT_direct_repeat' features.
# It has two modes, "local" uses the start of the gene as a coordinate origin, 
# and "global" uses the start of the chromosome.
#
# @param [Hash<Symbol, Bio::Sequence>] new_embl_hash The hash of Bio::Sequence objects, containing the 'CTTCTT_direct_repeat' features
# @param [String] mode The mode for the coordinate system, "local" or "global". If none of those, the default is "local"
# @param [String] filename The name of the output file
#
def write_gff3(new_embl_hash, mode, filename)

    #seqid # id of the landmark: gene id in local, chr number in global
    #source = "BioRuby"
    #type = "direct_repeat" # SO:0000314, direct repeat because in CTTCTT, CTT is repeated in the same orientation
    #start_pos # relative to the gene id in local, relative to the chr in global
    #end_pos # same as above
    #score = "."
    #strand # strand relative to the landmark
    #phase = "." # not a CDS
    #attributes # ID=unique_id;Name=CTTCTT_direct_repeat;

    puts "Writing the GFF3 file..."

    puts "WARNING: mode isn't 'local' or 'global', the default 'local' will be used" if mode != "local" && mode != "global"

    source = "BioRuby"
    type = "direct_repeat"
    score = "."
    phase = "."

    f = File.new(filename, "w")
    f.write("##gff-version 3\n") # writing the first line
    # iterating through every biosequence object
    new_embl_hash.each do |gene_id, biosequence|
        biosequence.features.each do |feature|
            next unless feature.feature == "CTTCTT_direct_repeat" # skip if it is not this feature

            # getting the rest of the elements of the gff3
            bio_location = feature.locations[0]
            # unique elements to each gff3 file
            if mode == "global"
                seqid = "Chr#{gene_id.to_s[2]}"
                chr_start_pos = biosequence.primary_accession.split(":")[3].to_i # chromosome:TAIR10:3:20119140:20121314:1 -> [3] is 20119140
                # for the positions, both the gene position in the chromosome and the feature position in the gene are 1-indexed
                # so we have to substract 1 to the sum
                start_pos = (chr_start_pos + bio_location.from.to_i - 1).to_s 
                end_pos = (chr_start_pos + bio_location.to.to_i - 1).to_s 
            else # default and if mode == "local"
                seqid = gene_id.to_s.upcase
                start_pos = bio_location.from
                end_pos = bio_location.to
            end
            # common elements in both gff3 files
            strand = feature.assoc["strand"]
            attributes = "ID=#{feature.assoc["ID"]};Name=#{feature.feature};"

            # joining the elements and writing them to the file
            elements = [seqid, source, type, start_pos, end_pos, score, strand, phase, attributes]
            entry = elements.join("\t") + "\n"
            f.write(entry)
        end
    end
    f.close
end


#
# Writes a report with the IDs of all the genes in the initial gene list that don't contain 'CTTCTT' in any of their exons. 
#
# @param [Array<Symbol>] gene_array The array of gene ids
# @param [Hash<Symbol, Bio::Sequence>] new_embl_hash The hash of Bio::Sequence objects, containing the 'CTTCTT_direct_repeat' features
# @param [String] filename The name of the output file
#
def write_report(gene_array, new_embl_hash, filename = "CTTCTT_report.txt")
    puts "Writing the report..."
    # getting the genes from gene_array that aren't in new_embl_hash
    not_feature_genes = gene_array.select {|gene_id| !new_embl_hash.keys.include?(gene_id)} 
    f = File.new(filename, "w") # opening the file
    f.write("Number of genes present in the initial txt: #{gene_array.length}\n")
    f.write("Number of genes without CTTCTT in any of their exons: #{not_feature_genes.length}\n")
    f.write("List of genes: \n")
    not_feature_genes.each do |gene_id|
        f.write("#{gene_id}\n")
    end
    f.close # closing the file
end