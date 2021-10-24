require_relative './Annotation.rb' # require_relative so that the path is relative to this file

class InteractionNetwork < Annotation

    # It inherits @annotations_hash, its attr_reader, and the methods add_one_annotation and add_multiple_annotations from Annotation

    @@all_networks = [] # array to store every InteractionNetwork object

    @@all_interactions = {} # hash to store every interaction found that involves one of the genes read from the file
    # gene1: [array of genes interacting with gene1]
    # To simplify searches, I'm duplicating information in favour of reducing time spent iterating through arrays:
    # if gene1 interacts with gene2, im storing both gene1->gene2 and gene2->gene1 interactions.
    # this way, when I want the genes that interact with gene1, I just do @@all_interactions[gene1], 
    # and don't have to search through the values arrays.

    @@gene_array = [] # array to store every gene id (as a lowercase symbol) read from the .txt file

    attr_accessor :net_gene_ids # Gene ids of the current InteractionNetwork object


    def initialize
        super # initializing Annotation



        
        @@all_networks << self # including the new InteractionNetwork into the network list
    end

    def self.add_interaction(gene1, gene2)
        # Class method
        # adds interactions gene1->gene2 and gene2->gene1 to the @all_interactions
        [gene1.to_sym, gene2.to_sym].each { |gene| 
            # for each gene, creating an empty array to store the gene's interactions if there aren't any already
            @@all_interactions[gene] = [] unless @@all_interactions.key?(gene1) 
        }
        @@all_interactions[gene1] |= [gene2] # adding gene2 to gene1's interaction array if it isn't already there
        @@all_interactions[gene2] |= [gene1] # adding gene1 to gene2's interaction array if it isn't already there
    end

    def self.get_interactions_from_all_interactions(id_list)
        # Class method
        # gets the interactions A-B from @@all_interactions where both A and B are part of id_list
        int_subset = {} # hash to store the results
        # for each unique id
        id_list.uniq.each do |id|
            int_subset[id] = [] # empty array for id
            @@all_interactions[id].each do |int_id| # for each int_id interacting with id
                if id_list.contains?(int_id) # if int_id is part of the id_list, there is an interaction between two members of the list
                    int_subset[id] |= [int_id] # adding int_id to the array of id if it's not already there
                    int_subset[int_id] = [] unless int_subset.key?(int_id) # creating an array for int_id if it doesn't exist
                    int_subset[int_id] |= [id] # adding id to the array of int_id if it's not already there
                end
            end
        end
        return int_subset unless int_subset.empty? # returns the results hash
        return nil # if empty
    end

    def self.read_gene_list(filename)
        # Class method
        # for each gene in the file, stores the id as a lowercase symbol in @@gene_array (if it doesn't exist already)
        IO.foreach(filename) do |gene|
            gene = gene.strip.downcase # removing whitespace (if any) and converting the letters to lowercase
            @@gene_array |= [gene.to_sym] if gene =~ /at\wg\d\d\d\d\d/ # storing the gene id as a symbol if it matches the regexp
        end
    end

    # For genes A, B in the gene list, I will consider A-B interactions, and A-X-B interactions, where X is not part of the gene list.
    def self.find_interactions_intact()
        @@gene_array.each do |gene_id|
            url = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene_id}?format=tab25"
            response = InteractionNetwork.fetch(url)
            if response
                puts response
                abort
            end
        end
    end







        





    

end