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

#path = "../Assignment2/ArabidopsisSubNetwork_GeneList.txt"



#
# <Description>
#
# @param [<Type>] gene_array <description>
#
# @return [<Type>] <description>
#
def get_embl(gene_array)
    unless gene_array && !gene_array.empty? # if there is nothing in the array, warning and exit the function, returning nil
        puts "WARNING: no genes in the gene array / no gene array"
        return nil
    end
    # else 
    embl_hash = {} # Hash to store {gene_id => Bio::EMBL object}
    gene_array = [gene_array] unless gene_array.is_a?(Array) # converting it into an array if it isn't (if there's only one element)
    gene_array.each do |gene_id| # for each gene in the array
        # Getting an EMBL entry from dbfetch using the database ensemblgenomesgene (that accepts AGI locus codes)
        url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{gene_id}&style=raw"
        response = fetch(url) # accessing the url
        if response
            entry = Bio::EMBL.new(response.body) # pass it the record as a string
            puts entry.class
            puts "The record is #{entry.definition} "
            unless embl_hash.keys.include?(gene_id)
                embl_hash[gene_id] = entry # storing it in the hash
            else
                puts "WARNING: #{gene_id} already contains an entry in the embl_hash"
            end
        end
    end
    return embl_hash # returns the hash
end

# if embl is a Bio::EMBL object
# embl.to_biosequence.seq gets the sequence => Bio::Sequence::NA
# embl.seq also does that

############
# Task 1:
# Using BioRuby, examine the sequences of the ~167 Arabidopsis genes from the last assignment 
# by retrieving them from whatever database you wish
############

############
# Task 2:
# Loop over every exon feature, and scan it for the CTTCTT sequence
############

def find_seq_in_exons(embl_hash)
    embl_hash.each do |gene_id, bio_embl| # iterating over the hash

        bio_embl_as_biosequence = bio_embl.to_biosequence # turning the Bio::EMBL into Bio::Sequence so that I can add features
        embl_seq = bio_embl.seq # getting the dna sequence as Bio::Sequence::NA

        # iterating through each feature of the original bio_embl
        # not using bio_embl_as_biosequence here because I will be adding features 
        # and it's not good to manipulate an object while iterating through it
        bio_embl.features.each do |feature| 
            next unless feature.feature == "exon" # skip if the feature is not an exon
            
            ###### vvvv for testing
            unless feature.assoc["note"].match(Regexp.new(gene_id.to_s, "i"))
                puts "this is being skipped"
                puts gene_id
                puts feature.assoc["note"]
            end
            ###### ^^^^ for testing

            next unless feature.assoc["note"].match(Regexp.new(gene_id.to_s, "i")) # skip if the exon is from another gene (because of overlapping or whatever)

            bio_location = feature.locations[0] # feature.locations is Bio::Locations, which is basically an array of Bio::Location objects
            exon_seq = embl_seq.subseq(bio_location.from, bio_location.to)

            
            ########################################
            ######## This comment is for myself to understand this:

            ##The sequence of the embl is always 5'3' and the exon can be on that one or on the complement one
            ######## https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=AT2G46340&style=raw
            ## that (embl) has the sequence 5'3', the exons are on the complement, so we would need the reverse complement of that
            ## if we translate this sequence as is, we dont get the proteins, bc the exons are on the complement
            ## doing: get_embl([:AT2G46340])[:AT2G46340].seq gives me the above sequence
            ## if I want to search for CTTCTT on the exons, I need to reverse complement the sequence or the query
            ## because the exons are on the complement strand

            ######## https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=AT2G46340&style=raw
            ## that (fasta) has the reverse complement already -> from here if we translate this we get the proteins
            ## here we would always look for CTTCTT because it is the correct strand (if we didn't want exons only)
            ########################################

            if bio_location.strand == +1 # the feature is on the current strand, we need to search for CTTCTT
                # To find the sequence, I'm using lookahead (?=) so that I can match overlapping expressions 
                # (https://stackoverflow.com/questions/41028602/find-overlapping-regexp-matches)
                # (https://stackoverflow.com/questions/5241653/ruby-regex-match-and-get-positions-of)
                start_f = my_seq.enum_for(:scan, /(?=(cttctt))/i).map { Regexp.last_match.begin(0) + 1} # 1-indexed
                
                if start_f.empty? # if there is no match

                    ###### Testing
                    puts "No match!"
                    puts gene_id
                    puts exon_seq
                    ###### Testing
    
                    next # next feature
                end

                # if there is a match
                positions_f = start_f.map {|pos| [pos, pos + 5]} unless start_f.empty? # 1-indexed

                ####### create feature en la misma strand

            elsif bio_location.strand == -1 # the feature is on the complement strand, we need to search for the reverse complement, AAGAAG
                # To find the sequence, I'm using lookahead (?=) so that I can match overlapping expressions 
                # (https://stackoverflow.com/questions/41028602/find-overlapping-regexp-matches)
                # (https://stackoverflow.com/questions/5241653/ruby-regex-match-and-get-positions-of)
                start_r = my_seq.enum_for(:scan, /(?=(aagaag))/i).map { Regexp.last_match.begin(0) + 1} # 1-indexed

                if start_r.empty? # if there is no match

                    ###### Testing
                    puts "No match!"
                    puts gene_id
                    puts exon_seq
                    ###### Testing
    
                    next # next feature
                end

                # if there is a match
                positions_r = start_r.map {|pos| [pos, pos + 5]} unless start_r.empty? # 1-indexed
                # create feature en la otra strand


            else
                puts "WARNING: no strand"
                next # skip
            end

            
            

            if start_f.empty? && start_r.empty? # if there is no match

                ###### Testing
                puts "No match!"
                puts gene_id
                puts exon_seq
                ###### Testing

                next # next feature
            end
            # if there is at least one match
            unless start_f.empty?
                

            end

            unless start_r.empty?
                

            end
        end
    end
end

############
# Task 3:
# Take the coordinates of every CTTCTT sequence and create a new Sequence Feature 
# (you can name the feature type, and source type, whatever you wish; the start and 
# end coordinates are the first ‘C’ and the last ‘T’ of the match.).  
# Add that new Feature to the EnsEMBL Sequence object.  
# (YOU NEED TO KNOW:  When you do regular expression matching in Ruby, use RegEx/MatchData objects; 
# there are methods that will tell you the starting and ending coordinates of the match in the string)
############

def create_feature(position, gene_id)
    return Bio::Feature.new(feature = 'repeat_sequence', 
                            position = place..holder, 
                            qualifiers = [Bio::Feature::Qualifier.new('gene', placeholder),
                                            Bio::Feature::Qualifier.new('sequence', 'CTTCTT'),
                                            Bio::Feature::Qualifier.new('strand', placeholder),
                                            Bio::Feature::Qualifier.new('start', placeholder),
                                            Bio::Feature::Qualifier.new('end', placeholder)])
end

############
# Task 4a:
# Once you have found them all, and added them all, loop over each one of your CTTCTT features 
# (using the #features method of the EnsEMBL Sequence object) and create a GFF3-formatted file of these features.
############

def write_gff3_local(parameters)
    write_gff3(mode = "local", parameters)
end

def write_gff3_global(parameters)
    write_gff3(mode = "global", parameters)
end

def write_gff3(mode, parameters)

    #seqid # id of the landmark: gene id in local, chr number in global
    #source = "BioRuby"
    #type = "direct_repeat" # SO:0000314, direct repeat because in CTTCTT, CTT is repeated in the same orientation
    #start_pos # relative to the gene id in local, relative to the chr in global
    #end_pos # same as above
    #score = "."
    #strand # relative to the landmark
    #phase = "." # not a CDS
    #attributes # ID=unique_id;Name=CTTCTT repeat;


end

############
# Task 4b:
# Output a report showing which (if any) genes on your list do NOT have exons with the CTTCTT repeat
############

def write_report

end

############
# Task 5:
#
#
############

############
# Task 6:
#
#
############

############
#
#
#
############