require_relative './DatabaseObject.rb' # require_relative so that the path is relative to this file
require_relative './SeedStockObject.rb'

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
        extension = output_name.split(".").last.to_sym # gets the extension (last element after splitting) and converts it to symbol
        sep = extension_separator.fetch(extension, "\t") # gets the corresponding separator, tab by default
        
        header = ["Seed_Stock", "Mutant_Gene_ID", "Last_Planted", "Storage", "Grams_Remaining"]
        
        f = File.new(output_name, "w") # opening the file
        f.write(header.join(sep) + "\n") # writing the header
        @all_entries.each do |stock| # iterating through each SeedStock object in the database
            elements = [stock.id, stock.mutant_gene_id, stock.last_planted, stock.storage, stock.grams_remaining.to_s]
            entry = elements.join(sep) + "\n"
            f.write(entry) # writing the next entry
        end
        f.close() # closing the file
    end
end