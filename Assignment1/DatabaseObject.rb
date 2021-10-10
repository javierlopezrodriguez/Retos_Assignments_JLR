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
    
    def get_object_by_id(input_value, attribute_name = :id) # by default: we are comparing input_value to the attribute @id
        
        # Gets an object from the database that has an attribute called attribute_name with value matching the input_value
        
        # If attribute_name is iterable, it first looks for the id in the first attribute.
        # If it doesn't find an object, it then checks the second attribute name, and so on.
        
        # Returns nil if there isn't any matching object (or the database is empty)
        
        unless attribute_name.respond_to? :each # if the attribute_name is not iterable
            attribute_name = [attribute_name] # converts it into an array of 1 element
        end
        
        attribute_name.each do |attr_name| # for each attribute name
            unless @all_entries.empty? # if the database is not empty
                @all_entries.each do |obj| # for each object in the database
                    
                    # Accessing the attribute attr_name:
                    # (https://stackoverflow.com/questions/1407451/calling-a-method-from-a-string-with-the-methods-name-in-ruby)
                    # I'm creating the method, and then calling it with attribute.call()
                    # This is equivalent to calling obj.attr_name, but allows me to not hard-code it
                    # (so I can use this method with HybridStockDatabase, because HybridStock has two ids called @parent1, @parent2)
                    # If I don't do this, I have to either:
                    #    - repeat this method in HybridStockDatabase changing only a few lines
                    #    - make it so that HybridStockDatabase can't use this method, because HybridStock.id doesn't exist.
                    
                    obj_attr = obj.method(attr_name) # creating the method
                    return obj if obj_attr.call() == input_value # return obj if obj.attr_name == input_value
                    # The return will exit the function if it found an object.
                end
            end
        end
        
        # Code below only gets executed if no object has been found
        unless @all_entries.empty? # If there are objects in @all_entries
            puts "WARNING: No #{@all_entries[0].class} object found with ID: #{input_value}"
            return nil
        else # if the array is empty
            puts "WARNING: You're looking for an object but there are no objects in the database."
            return nil
        end
    end
end