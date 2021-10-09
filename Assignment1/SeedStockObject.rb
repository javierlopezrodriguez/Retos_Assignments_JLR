class SeedStock
  
    #Attributes:
      #@id:
      #@mutant_gene_id:
      #@gene: nil by default, or the corresponding Gene object if there is a GeneDatabase with an object with id @mutant_gene_id
      #@last_planted:
      #@storage:
      #@grams_remaining:
    
    # Attribute accessors:
    attr_accessor :id, :mutant_gene_id, :gene, :last_planted, :storage, :grams_remaining
    
    def initialize(params = {})
        @id = params.fetch(:id, "Unknown stock ID")
        @last_planted = params.fetch(:last_planted, "Not planted")
        @storage = params.fetch(:storage, "Unknown location")
        @grams_remaining = params.fetch(:grams_remaining, 0)
        @mutant_gene_id = params.fetch(:mutant_gene_id, "Unknown mutant gene id.") 
        @gene = nil # by default
        
            
            
            #####   EN QUÉ ORDEN VAN A IR LAS COSAS
          
    end
    
    def add_gene_object(gene_database)
        
        # adding the corresponding Gene object to the SeedStock object
        # if there is a GeneDatabase object and it contains a Gene object matching its id
        # I've left it outside of the initializer so that SeedStock and SeedStockDatabase could be used without Gene or GeneDatabase
        
        @gene = gene_database.get_object_by_id(@mutant_gene_id) # the Gene object if it exists, or nil if it doesn't
    end
        
        
        
end