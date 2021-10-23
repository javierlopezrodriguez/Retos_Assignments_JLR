require_relative './Annotation.rb' # require_relative so that the path is relative to this file

class InteractionNetwork < Annotation

    # It inherits @annotations_hash, its attr_reader, and the methods add_one_annotation and add_multiple_annotations from Annotation

    @@network_array = [] # array to store every InteractionNetwork object

    @@all_interactions = {} # hash to store every interaction found that involves one of the genes read from the file
    # gene1: [array of genes interacting with gene1]
    # To simplify searches, I'm duplicating information in favour of reducing time spent iterating through arrays:
    # if gene1 interacts with gene2, im storing both gene1->gene2 and gene2->gene1 interactions.
    # this way, when I want the genes that interact with gene1, I just do @@all_interactions[gene1], 
    # and don't have to search through the values arrays.

    @@gene_array = [] # array to store every gene id (as a lowercase symbol) read from the .txt file


    def initialize
        super # initializing Annotation



        @@network_array << self # including the new InteractionNetwork into the network list
    end

    def self.add_interaction(gene1, gene2)
        [gene1.to_sym, gene2.to_sym].each { |gene| 
            # for each gene, creating an empty array to store the gene's interactions if there aren't any already
            @@all_interactions[gene] = [] unless @@all_interactions.key?(gene1) 
        }
        @@all_interactions[gene1] |= gene2 # adding gene2 to gene1's interaction array if it isn't already there
        @@all_interactions[gene2] |= gene1 # adding gene1 to gene2's interaction array if it isn't already there
    end

    def self.read_gene_list(filename)
        # Class method
        # for each gene in the file, stores the id as a lowercase symbol in @@gene_array (if it doesn't exist already)
        IO.foreach(filename) {|gene|
            gene = gene.strip.downcase # removing whitespace (if any) and converting the letters to lowercase
            @@gene_array |= [gene.to_sym] if gene =~ /at\wg\d\d\d\d\d/ # storing the gene id as a symbol if it matches the regexp
        }
    end

    



        





    

end