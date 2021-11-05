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
        embl_seq = bio_embl.seq
        bio_embl.features.each do |feature| # for each feature
            next unless feature.feature == "exon" # skip if the feature is not an exon
            
            ###### vvvv for testing
            unless feature.assoc["note"].match(Regexp.new(gene_id.to_s, "i"))
                puts "this is being skipped"
                puts gene_id
                puts feature.assoc["note"]
            end
            ###### ^^^^ for testing

            next unless feature.assoc["note"].match(Regexp.new(gene_id.to_s, "i")) # skip if the exon is from another gene (because of overlapping or whatever)

            exon_seq = embl_seq.subseq(feature.location.from, feature.location.to)

            # using lookahead (?=) so that I can match overlapping expressions (https://stackoverflow.com/questions/41028602/find-overlapping-regexp-matches)
            regexp_f = Regexp.new(/(?=(CTTCTT))/i) 
            regexp_r = Regexp.new(/(?=(AAGAAG))/i)

            match_f = exon_seq.match(regexp_f)
            match_r = exon_seq.match(regexp_r)

            unless match_f || match_r # if there is no match

                ###### Testing
                puts "No match!"
                puts gene_id
                puts exon_seq
                ###### Testing

                next
            end
            # if there is at least one match
            if match_f

            end

            if match_r

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

############
# Task 4a:
# Once you have found them all, and added them all, loop over each one of your CTTCTT features 
# (using the #features method of the EnsEMBL Sequence object) and create a GFF3-formatted file of these features.
############

############
# Task 4b:
# Output a report showing which (if any) genes on your list do NOT have exons with the CTTCTT repeat
############

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