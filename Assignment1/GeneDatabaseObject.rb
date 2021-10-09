class GeneDatabase < Database
        
    # GeneDatabase inherits #initialize, #load_from_file and #get_object_by_id from Database
    
    # Helper method used by #load_from_file
    # Overriding the empty method #create_and_store_object from Database
    # because this is different for every Class.
    def create_and_store_object(params)
        new_gene = Gene.fabricate(params) # calling fabricate instead of new because we are checking the format of the id
        @all_entries << new_gene
    end
    
end