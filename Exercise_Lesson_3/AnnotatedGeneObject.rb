require '../Assignment1/GeneObject'

class AnnotatedGene < Gene
    
    attr_accessor :dna_seq, :prot_seq
    
    def initialize(params = {})
        Gene.fabricate(params)
        @dna_seq = params.fetch(:dna_seq, nil)
        @prot_seq = params.fetch(:prot_seq, nil)
    end
    
    def AnnotatedGene.from_gene(gene_object)
        
    end
end