require './DatabaseObject.rb'
require './GeneObject.rb'

class GeneDatabase < Database    
    
    # GeneDatabase inherits #initialize, #load_from_file and #get_object_by_id from Database
    
    # Helper method used by #load_from_file
    # Overriding the empty method #create_and_store_object from Database
    # because this is different for every Class.
    def create_and_store_object(params)
        new_gene = Gene.fabricate(params) # calling fabricate instead of new because we are checking the format of the id
        @all_entries << new_gene
    end
    
    def set_linked_genes(gene1, gene2)
        # Sets the @linked attribute for each gene to the id of the other gene.
        
        # Getting the ids from the genes (redundant when calling #set_linked_genes_by_id)
        id1 = gene1.id
        id2 = gene2.id
        
        # Warning messages if one or both genes aren't in the database,
        # updating the @linked attribute if both are
        case
            when gene1.nil? && gene2.nil?
                puts "WARNING: Genes #{id1} and #{id2} aren't in the database."
            when gene1.nil?
                puts "WARNING: Gene #{id1} isn't in the database."
            when gene2.nil?
                puts "WARNING: Gene #{id2} isn't in the database."
            else # when both genes exist in the database
                gene1.linked = id2
                gene2.linked = id1
        end
    end
    
    def set_linked_genes_by_id(id1, id2)
        # Sets the @linked attribute for each gene to the id of the other gene.
        
        # Getting the genes by their ids
        gene1 = get_object_by_id(id1)
        gene2 = get_object_by_id(id2)
        
        # Calling #set_linked_genes
        set_linked_genes(gene1, gene2)
    end
end