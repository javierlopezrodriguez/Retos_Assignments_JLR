class HybridCrossDatabase < Database
        
    # HybridCrossDatabase inherits #initialize and #load_from_file from Database
    
    # Helper method used by #load_from_file
    # Overriding the empty method #create_and_store_object from Database
    # because this is different for every Class.
    def create_and_store_object(params)
        new_cross = HybridCross.new(params)
        @all_entries << new_cross
    end
    
    #Overriding #get_object_by_id because HybridCross doesn't have an attribute @id
    def get_object_by_id(input_id)
        
        # Gets an object from the database that has an attribute @parent1 matching the input_id.
        # If there is none, it repeats the search with @parent2.
        # Returns nil if there isn't any matching object (or the database is empty).
        
        unless @all_entries.empty? # if the array is not empty
            # Checking for @parent1 attribute for each HybridCross object
            @all_entries.each do |item| # iterate through the array
                next unless item.parent1 == input_id # go to the next object if the id doesn't match
                return item # return the object if it matches, exiting the method
            end
            # Checking for @parent2 attribute for each HybridCross object, only gets executed if the previous failed
            @all_entries.each do |item| # iterate through the array
                next unless item.parent2 == input_id # go to the next object if the id doesn't match
                return item # return the object if it matches, exiting the method
            end
            # This only gets executed if no object has been found but @all_entries has objects
            puts "No #{@all_entries[1].class} object found with ID: #{input_id}" # warning message
            return nil
        else # if the array is empty
            puts "There are no objects in the database" # warning message
            return nil
        end  
    end
    
    def annotate_linked_genes(stock_database, gene_database)
        @all_entries.each do |cross|
            if cross.linked # not false or nil
                # getting the seed stock ids from the HybridCross objects
                cross_id_p1, cross_id_p2 = cross.parent1, cross.parent2
                # getting the SeedStock objects corresponding to those ids from the stock database
                stock_p1 = stock_database.get_object_by_id(cross_id_p1)
                stock_p2 = stock_database.get_object_by_id(cross_id_p2)
                # if both are found
                unless stock_p1.nil? || stock_p2.nil?
                    # getting the gene ids from the SeedStock objects
                    # if the SeedStock objects contain the Gene objects, retrieve them and link both genes that way
                    # if the SeedStock objects don't contain the Gene objects, link them using their ids
                    unless stock_p1.gene.nil? || stock_p2.gene.nil? # if the Gene objects are inside the SeedStock objects
                        gene_p1, gene_p2 = stock_p1.gene, stock_p2.gene
                        gene_database.set_linked_genes(gene_p1, gene_p2)
                    else # if one or both aren't
                        gene_id_p1, gene_id_p2 = stock_p1.mutant_gene_id, stock_p2.mutant_gene_id
                        gene_database.set_linked_genes_by_id(gene_id_p1, gene_id_p2)
                    end
                end
            end
        end
    end
end