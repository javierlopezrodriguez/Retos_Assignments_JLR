class Gene
  
    #Attributes:
      #@id:
      #@name:
      #@mutant_phenotype:
      #@linked: 
    
    # Attribute accessors for @name, @mutant_phenotype and @linked
    attr_accessor :name, :mutant_phenotype, :linked
    # Attribute reader only for @id
    attr_reader :id # only want to get an @id, not to change it.
    # The only way to set an @id should be when creating an instance of Gene.
    
    # For initializing a Gene object, I'm using the factory method adapted from
    # https://stackoverflow.com/questions/15499613/ruby-cancel-object-creation
    # because I want to create the object only if the @id is formatted correctly
    # and this way seems cleaner to me.
    
    # Basic initializer
    # (we won't use it directly, to create an object we will call Gene.fabricate)
    def initialize (params)
        @id = params.fetch(:Gene_ID) # no default because this only gets called if it is correct
        @name = params.fetch(:Gene_name, "unknown_name")
        @mutant_phenotype = params.fetch(:mutant_phenotype, "unknown_mutant_phenotype")
        @linked = nil # default value
    end
    
    # Fabricator
    def self.fabricate (params = {})
        # This is the method that will be called to create an object
        # It checks if the id is correct:
        #   if it isn't, it prints a message and returns nil, cancelling the creation.
        #   if it is, it calls the initializer
        input_id = params.fetch(:Gene_ID, "No ID provided")
        unless Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/).match(input_id) # if the id format doesn't match the regexp
            puts "The entry with ID: #{input_id} doesn't have a correct ID. It is being ignored."
            return nil # returns nil instead of creating an instance of Gene.
        else
            new(params) # if the id is correct, it calls initialize, creating the instance of Gene.
        end
    end
    
    
end