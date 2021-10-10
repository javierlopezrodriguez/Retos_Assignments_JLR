class Database
    # Generic class over which StockDatabase and GeneDatabase will be built.
    
    #Attributes:
        # @all_entries: array of every object in the database
    
    attr_accessor :all_entries
    
    #Methods:
        #initialize
        #load_from_file: method that reads a .csv and creates an object for each line
            # Because this is a generic class, the object creation is on a different helper method
        #create_and_store_object: helper method for load_from_file
            # Because this is a generic class, this method is empty and must be overriden
            # by the other classes that inherit from Database.
        #get_object_by_id: method that returns an object with a given id from @all_entries, if it exists
        
    def initialize()
        @all_entries = [] # empty list to store all the objects
    end
    
    def load_from_file(filepath, separator = "\t")
        
        # Opens a .csv file (by default a .tsv) with a header,
        # creates an object for each non-header line and inserts it into the database
        
        require "csv" # using the csv library
        
        # using a begin - rescue block to handle exceptions when opening the file
        begin 
            # Opening the file as read (mode = "r" by default).
            # Including the separator (default tab), skip_blanks: true so that it skips empty lines,
            # and headers: true, header_converters: symbol so that it processes the header and converts it to symbol
            # header_converters: :symbol also turns the string into snake_case ("Gene_Name" -> :gene_name)
            CSV.foreach(filepath, col_sep: separator, skip_blanks: true, headers: true, header_converters: :symbol) do |line|
                # line is a hash-like object, indexable by the header symbols
                # creating the object and storing it in @all_entries
                create_and_store_object(line)
            end
        rescue Errno::ENOENT # handling the missing file exception
            puts "ERROR: Can't find the file #{filepath}"
        end
    end
    
    # Helper method used by #load_from_file
    # Depending on the database, the stored object is of a different class.
    # That's why this method must be overriden by the child classes.
    def create_and_store_object(params)
        # empty method
    end
    
    def get_object_by_id(input_id)
        
        # Gets an object from the database that has an attribute @id matching the input_id
        # or returns nil if there isn't any matching object (or the database is empty)
        
        unless @all_entries.empty? # if the array is not empty
            @all_entries.each do |item| # iterate through the array
                next unless item.id == input_id # go to the next object if the id doesn't match
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
    
end