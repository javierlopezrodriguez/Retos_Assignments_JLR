require 'rest-client'
require 'json'

class Annotation

    # General use Annotation object

    # Attributes:
    # @annotations_hash: a hash that, for each annotation type (key), contains an array or a hash (depending on the annotation type)
    # example if an annotation type contains an array: (in this case an array of arrays)
    # @annotations_hash["GO"] could contain [["GO:0005634", "C:nucleus", "IEA:UniProtKB-SubCell"], ["GO:0000151", "C:ubiquitin ligase complex", "IBA:GO_Central"]]
    # same example if an annotation type contains a hash:
    # @annotations_hash["GO"] could contain {"GO:000534" => ["C:nucleus", "IEA:UniProtKB-SubCell"], "GO:0000151" => ["C:ubiquitin ligase complex", "IBA:GO_Central"]}
    
    attr_accessor :annotations_hash

    # on initialization the hash is empty
    def initialize
        @annotations_hash = {}
    end

    # Function to add one annotation as an array or an array of arrays
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

    # Function to add one annotation as a hash
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

    '''
Annotate it with any KEGG Pathways the interaction network members are part of

both KEGG ID and Pathway Name

Annotate it with the GO Terms associated with the total of all genes in the network

BUT ONLY FROM THE biological_process part of the GO Ontology!

Both GO:ID and GO Term Name
    '''

    # Function fetch to access an URL via code, donated by Mark Wilkinson.
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
            return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue RestClient::Exception => e
            $stderr.puts e.inspect
            response = false
            return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue Exception => e # generic
            $stderr.puts e.inspect
            response = false
            return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end 

    def get_kegg_annotation()
        # makes the array into an array in case there is only one element
        id_list = [id_list] unless id_list.respond_to? :each
        # for each id in the array
        id_list.each do |id|
            # this URL works with AGI locus codes
            url = "http://togows.org/entry/kegg-genes/ath:#{id}/pathways.json" # id can be a symbol, there is implicit conversion to string
            response = fetch(url)
            if response # if fetch was successful
                body = JSON.parse(response.body) # turns the JSON file into a ruby data structure made of arrays and hashes
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

    def get_go_annotation(id_list)
        # makes the array into an array in case there is only one element
        id_list = [id_list] unless id_list.respond_to? :each
        # for each id in the array
        id_list.each do |id|
            # this URL works with AGI locus codes
            url = "http://togows.org/entry/ebi-uniprot/#{id}/dr.json" # id can be a symbol, there is implicit conversion to string
            response = fetch(url)
            if response # if fetch was successful
                body = JSON.parse(response.body) # turns the JSON file into a ruby data structure made of arrays and hashes
                body.each do |hash|
                    hash["GO"].each do |go_info|
                        # go_info is an array, for instance: ["GO:0080671", "P:phosphatidylglycerol metabolic process", "IMP:TAIR"]
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