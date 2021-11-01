require 'rest-client'
require 'json'

# == Annotation
#
# Class that represents an annotation object, containing a hash to store annotations,
# functions to add annotations in different formats, and functions to search for KEGG and GO annotations.
#
# == Summary
# 
# This can be used to find and store annotations.
#
class Annotation

    # General use Annotation object

    # @annotations_hash: a hash that, for each annotation type (key), contains an array or a hash (depending on the annotation type)
    # example if an annotation type contains an array: (in this case an array of arrays)
    # @annotations_hash["GO"] could contain [["GO:0005634", "C:nucleus", "IEA:UniProtKB-SubCell"], ["GO:0000151", "C:ubiquitin ligase complex", "IBA:GO_Central"]]
    # same example if an annotation type contains a hash:
    # @annotations_hash["GO"] could contain {"GO:000534" => ["C:nucleus", "IEA:UniProtKB-SubCell"], "GO:0000151" => ["C:ubiquitin ligase complex", "IBA:GO_Central"]}
    
    # Get/Set the hash that stores the annotations
    # @!attribute [rw]
    # @return [Hash] The hash to store the annotations
    attr_accessor :annotations_hash

    #
    # Create a new instance of Annotation
    #
    # @param [Hash] params Hash of parameters
    #
    def initialize(params = {})
        @annotations_hash = {} # on initialization the hash is empty
    end

    #
    # Adds one annotation as an array or as an array of arrays to @annotations_hash
    #
    # @param [Symbol] key Annotation type, key of the hash @annotations_hash
    # @param [Array] value Array of elements to be added to @annotations_hash[key]
    #
    def add_one_annotation_as_array(key, value)
        @annotations_hash[key] = [] unless @annotations_hash.key?(key) # empty array if there isn't any with that key
        if @annotations_hash[key].is_a?(Array)
            @annotations_hash[key] << value unless @annotations_hash[key].include?(value)  # appending value to the empty array if it doesn't exist already
        else # @annotations_hash[key] isn't an Array (it existed previously and contains a different data structure)
            puts "WARNING: the annotation of type #{key} is not an Array"
        end
        # if value is only one element, we will have [a, b, c, ...]
        # if value is an array, we will have [[a1, a2], [b1, b2], ...]
    end

    #
    # Adds one annotation as a hash to @annotations_hash
    #
    # @param [Symbol] key Annotation type, key of the hash @annotations_hash
    # @param [Hash] input_hash Hash of elements to be added to @annotations_hash[key]
    #
    def add_one_annotation_as_hash(key, input_hash)
        @annotations_hash[key] = {} unless @annotations_hash.key?(key) # empty hash if there isn't anything with that key
        input_hash.each do |id, values|
            # if @annotations_hash[key] isn't a Hash (it existed previously and contains a different data structure):
            puts "WARNING: the annotation of type #{key} is not a Hash" unless @annotations_hash[key].is_a?(Hash)
            # if @annotations_hash[key] is a Hash, store values directly if @annotations_hash[key][id] doesn't exist:
            @annotations_hash[key][id] = values if @annotations_hash[key].is_a?(Hash) && !@annotations_hash[key].key?(id)
            # if @annotations_hash[key] is a Hash, @annotations_hash[key][id] already exists, and the values are different, give a warning:
            if @annotations_hash[key].is_a?(Hash) && @annotations_hash[key].key?(id) && @annotations_hash[key][id] != values
                puts "WARNING: in the annotation of type #{key}, the entry #{id} already contained #{@annotations_hash[key][id].to_s}."
                puts "#{values.to_s} is not being added."
            end
        end
    end

    # Function fetch to access an URL via code, donated by Mark Wilkinson.
    # Making it a class method because I want to access it when no instances have been created

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
    def self.fetch(url, headers = {accept: "*/*"}, user = "", pass="")
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
    # Given an id list, gets the KEGG annotations (KEGG ID and KEGG pathway) for each id
    # and stores it in @annotations_hash[:KEGG] 
    #
    # @param [Array<Symbol>] id_list The list of ids
    #
    def get_kegg_annotation(id_list)
        # makes the array into an array in case there is only one element
        id_list = [id_list] unless id_list.respond_to? :each
        # for each id in the array
        id_list.each do |id|
            # this URL works with AGI locus codes
            url = "http://togows.org/entry/kegg-genes/ath:#{id}/pathways.json" 
            response = Annotation.fetch(url)
            if response # if fetch was successful
                body = JSON.parse(response.body) # turns the JSON file into a ruby data structure made of arrays and hashes
                next if body.empty? # next id if there is nothing inside the hash
                # for each {kegg_id: kegg_pathway_name} hash in body
                body.each do |kegg_hash|
                    # for each hash
                    kegg_hash.each do |kegg_path_id, kegg_path_name|
                        add_one_annotation_as_hash(:KEGG, {kegg_path_id => kegg_path_name})
                    end
                end
            end
        end
    end

    #
    # Given an id list, gets the GO annotations (GO ID and biological process) for each id
    # if the annotation is a biological process (P:)
    # and there is experimental or high-throughput experimental evidence
    #
    # @param (see #get_kegg_annotation)
    #
    def get_go_annotation(id_list)
        # makes the array into an array in case there is only one element
        id_list = [id_list] unless id_list.respond_to? :each
        # for each id in the array
        id_list.each do |id|
            # this URL works with AGI locus codes
            url = "http://togows.org/entry/ebi-uniprot/#{id}/dr.json" 
            response = Annotation.fetch(url)
            if response # if fetch was successful
                body = JSON.parse(response.body) # turns the JSON file into a ruby data structure made of arrays and hashes
                body.each do |hash|
                    next unless hash.key?("GO") # next id if there aren't GO annotations
                    hash["GO"].each do |go_info|
                        # go_info is an array, for instance: ["GO:0080671", "P:phosphatidylglycerol metabolic process", "IMP:TAIR"]

                        # I'm filtering for the evidence type, adding only those annotations inferred from experiments or from high-throughput experiments
                        # http://geneontology.org/docs/guide-go-evidence-codes/
                        # To do that, instead of looking for those codes, I'm looking for the annotations NOT inferred from experiments and skipping them
                        not_exp_evidence_codes = ["IBA", "IBD", "IKR","IRD", "ISS", "ISO", "ISA", "ISM", "IGC", "RCA", "TAS", "NAS", "IC", "ND", "IEA"]
                        matchobj = go_info[2].match(/([A-Z]{2,3}):.*/)
                        next if not_exp_evidence_codes.include?(matchobj[1]) # skipping the GO annotation if the evidence is one of those types
                        
                        # getting only the biological processes, whose second field (go_info[1]) starts with 'P:'
                        matchobj = go_info[1].match(/P:(.*)/)
                        if matchobj
                            go_id, go_process = go_info[0], matchobj[1]
                            # adding the annotation in the format: {"GO:0080671" => "phosphatidylglycerol metabolic process"}
                            add_one_annotation_as_hash(:GO, {go_id => go_process})
                        end
                    end
                end
            end
        end
    end
end