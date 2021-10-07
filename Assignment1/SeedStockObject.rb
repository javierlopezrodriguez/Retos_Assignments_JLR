class SeedStock
  
    #Attributes:
      #@stockid:
      #@gene: the corresponding Gene object.
      #@last_planted:
      #@storage:
      #@grams_remaining:
    
    # Attribute accessors:
    attr_accessor :stockid, :gene, :last_planted, :storage, :grams_remaining
    
    def initialize(params = {})
        @stockid = params.fetch(:stockid, "Unknown stock ID")
        @last_planted = params.fetch(:last_planted, "Not planted")
        @storage = params.fetch(:storage, "Unknown location")
        @grams_remaining = params.fetch(:grams_remaining, 0)
        
        mutant_gene_id = params.fetch(:mutant_gene_id, "Unknown mutant gene id.")
        mutant_gene = Gene.return_gene_with_id(mutant_gene_id)
        unless mutant_gene.nil? # if it is not nil, the Gene object with that id exists.
            @gene = mutant_gene
        else # if it is nil, no Gene object exists with that id.
            @gene = Gene.fabricate({mutant_gene_id: mutant_gene_id}) # Creating a gene object.
            
            
            
            #####   EN QUÉ ORDEN VAN A IR LAS COSAS
          
        end
        
        
        
    end
end