class StockDatabase < Database

        #the object should have a #load_from_file($seed_stock_data.tsv)
        #the object should access individual SeedStock objects based on their ID (e.g. StockDatabase.get_seed_stock('A334')
        #the object should have a #write_database('new_stock_file.tsv')
        
    # StockDatabase inherits #initialize, #load_from_file and #get_object_by_id from Database
    
    # Helper method used by #load_from_file
    # Overriding the empty method #create_and_store_object from Database
    # because this is different for every Class.
    def create_and_store_object(params)
        new_seed_stock = SeedStock.new(params)
        @all_entries << new_seed_stock
    end
    
    
    def write_database(output_name)
        
    end
end