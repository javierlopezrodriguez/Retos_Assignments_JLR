class Gene
  
    attr_accessor :name
    attr_accessor :mutant_phenotype
    
    def initialize (params = {}) # hash with parameters for initialization
        @name = params.fetch(    ) # COMPLETE
        @mutant_phenotype = params.fetch(    ) # COMPLETE
        
        input_id = params.fetch(     ) # COMPLETE
        # Checking that the ID has a correct format
        id_regexp = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/) # creating the regexp for the ID
        if id_regexp.match(input_id) # if the format is correct (the id matches the regexp)
            @id = input_id
        else # if the format is incorrect
            
        end
        
        
    if mesh_regex.match(newvalue)
      @mesh = newvalue
    end
  end
  
  def initialize (params = {})
    @name = params.fetch(:name, 'unknown disease')
    @mesh = params.fetch(:mesh, "0000000") # this is the default, i'm not validating this one
  end
        
    end
    
end