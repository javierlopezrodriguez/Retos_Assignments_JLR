require './DatabaseObject.rb'
require './SeedStockObject.rb'

class StockDatabase < Database
        
    # StockDatabase inherits #initialize, #load_from_file and #get_object_by_id from Database
    
    # Helper method used by #load_from_file
    # Overriding the empty method #create_and_store_object from Database
    # because this is different for every Class.
    def create_and_store_object(params)
        new_seed_stock = SeedStock.new(params)
        @all_entries << new_seed_stock
    end
    
    def write_database(output_name)
        # It supports .csv and .tsv files. The extension must be the last part of the filename.
        extension_separator = {tsv: "\t", csv: ","}
        extension = output_name.split(".").last # gets the extension
        sep = extension_separator.fetch(extension, "\t") # gets the corresponding separator, tab by default
        
        header = ["Seed_Stock", "Mutant_Gene_ID", "Last_Planted", "Storage", "Grams_Remaining"]
        File.write(output_name, header.join(sep), mode: "w") # writing the header
        @all_entries.each do |stock| # iterating through each SeedStock object in the database
            entry = stock.id + sep + stock.mutant_gene_id + sep + stock.last_planted + sep + stock.storage + sep + stock.grams_remaining.to_s
            File.write(output_name, entry, mode: "a") # appending the rest of the seedstocks.
        end    
    end
end