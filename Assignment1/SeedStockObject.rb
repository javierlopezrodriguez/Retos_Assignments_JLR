class SeedStock
  
    #Attributes:
      #@id: seed stock id
      #@mutant_gene_id: id of the mutant gene
      #@gene: nil by default, or the corresponding Gene object if there is a GeneDatabase with an object with id @mutant_gene_id
      #@last_planted: date 
      #@storage: storage location
      #@grams_remaining: amount remaining in grams
    
    # Attribute accessors:
    attr_accessor :id, :mutant_gene_id, :gene, :last_planted, :storage, :grams_remaining
    
    def initialize(params = {})
        @id = params.fetch(:seed_stock, "Unknown stock ID")
        @last_planted = params.fetch(:last_planted, "Not planted")
        @storage = params.fetch(:storage, "Unknown location")
        @grams_remaining = params.fetch(:grams_remaining, 0).to_f # converting the string to float
        @mutant_gene_id = params.fetch(:mutant_gene_id, "Unknown mutant gene id.") 
        @gene = nil # by default
    end
    
    def add_gene_object(gene_database)
        
        # adding the corresponding Gene object to the SeedStock object
        # if there is a GeneDatabase object and it contains a Gene object matching its id
        # I've left it outside of the initializer so that SeedStock and SeedStockDatabase could be used without Gene or GeneDatabase
        
        @gene = gene_database.get_object_by_id(@mutant_gene_id) # the Gene object if it exists, or nil if it doesn't
    end
    
    def decrease_quantity(grams)
        new_amount = @grams_remaining - grams
        case # different warnings depending on the final amount
            when new_amount < 0.0
                puts "WARNING: For Stock #{@id}, grams remaining are less than cero (#{new_amount}), it has been set to 0."
                @grams_remaining = 0 # can't be negative
            when new_amount > 0.0
                @grams_remaining = new_amount # updating the amount
            else # equal to 0
                puts "WARNING: We have run out of Seed Stock #{@id}."
                @grams_remaining = 0 # updating the amount
        end
    end
end