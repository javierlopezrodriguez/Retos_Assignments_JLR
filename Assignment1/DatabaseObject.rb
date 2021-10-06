class StockDatabase

        #the object should have a #load_from_file($seed_stock_data.tsv)
        #the object should access individual SeedStock objects based on their ID (e.g. StockDatabase.get_seed_stock('A334')
        #the object should have a #write_database('new_stock_file.tsv')
        
        
        
        
    def load_from_file(filepath) # COMPLETE, FILENAME
        while File.open(filepath, "r") do |file| # opening the file
            header = Array.new # empty array for the header of the file
            file.each do |line| # iterate through each line in file
                if header.empty? # if header is empty
                    header << line.split("\t") # split each field by \t and store them in the array
                else # the header has been already read
                    # create a SeedStock object for each seed stock in the database
                  
                end
                
                    #code
            end
                
               
        end
    end
    
    def get_seed_stock(stock_id)
        
    end
    
    def write_database(output_name)
        
    end
    
end