require_relative './DatabaseObject.rb' # require_relative so that the path is relative to this file
require_relative './HybridCrossObject.rb'

class HybridCrossDatabase < Database
        
    # HybridCrossDatabase inherits #initialize, #load_from_file and #get_object_by_id from Database
    
    # Helper method used by #load_from_file
    # Overriding the empty method #create_and_store_object from Database
    # because this is different for every Class.
    def create_and_store_object(params)
        new_cross = HybridCross.new(params)
        @all_entries << new_cross
    end
    
    # It is not used in this exercise, but to use #get_object_by_id in this class,
    # we would have to do the following:
    # value = "example_id" # just an example
    # get_object_by_id(input_value = value, attribute_name = [:parent1, :parent2])
    # because HybridStock doesn't have an @id attribute.
    # This would look for a HybridStock object with @parent1 == "example_id". If there was none,
    # it would then look for a HybridStock object with @parent2 == "example_id".
    
    def annotate_linked_genes_and_report(stock_database, gene_database)
        
        # Checks every HybridCross object to see if both genes are linked. If they are,
        # it sets the @linked attribute for each Gene object to the id of the other.
        # At the end, it prints a report with every linkage.
        
        linked_report = [] # Stores the strings "A is linked to B" "B is linked to A" for every pair of linked genes
        
        @all_entries.each do |cross| # iterates through all the crosses
            if cross.linked # not false or nil
                # getting the seed stock ids from the HybridCross objects
                cross_id_p1, cross_id_p2 = cross.parent1, cross.parent2
                # getting the SeedStock objects corresponding to those ids from the stock database
                stock_p1 = stock_database.get_object_by_id(cross_id_p1)
                stock_p2 = stock_database.get_object_by_id(cross_id_p2)
                # if both are found
                unless stock_p1.nil? || stock_p2.nil?
                    # if the SeedStock objects contain the Gene objects, retrieve them and link both genes that way
                    # if the SeedStock objects don't contain the Gene objects, link them using their ids
                    unless stock_p1.gene.nil? || stock_p2.gene.nil? # if the Gene objects are inside the SeedStock objects
                        gene_p1, gene_p2 = stock_p1.gene, stock_p2.gene
                        gene_database.set_linked_genes(gene_p1, gene_p2) # setting @linked attribute using the genes
                        gene_id_p1, gene_id_p2 = gene_p1.id, gene_p2.id # getting the ids anyway for the final report
                    else # if one or both aren't
                        gene_id_p1, gene_id_p2 = stock_p1.mutant_gene_id, stock_p2.mutant_gene_id
                        gene_database.set_linked_genes_by_id(gene_id_p1, gene_id_p2) #setting @linked attribute using the gene ids
                    end
                    # Printing the message:
                    puts "Recording: #{gene_id_p1} is genetically linked to #{gene_id_p2} with chi square score #{cross.estimator} (cutoff probability: #{cross.cutoff_probability})."
                    # Adding the messages to the linked_report array
                    linked_report << "#{gene_id_p1} is linked to #{gene_id_p2}"
                    linked_report << "#{gene_id_p2} is linked to #{gene_id_p1}"
                else
                    puts "WARNING: one or both of the stocks #{cross_id_p1}, #{cross_id_p2} aren't in the StockDatabase"
                end
            end
        end
        # Printing the report
        puts "\nFinal hybrid cross report:"
        linked_report.each do |message| puts message end
    end
end