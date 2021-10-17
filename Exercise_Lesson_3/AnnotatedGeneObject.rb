require_relative '../Assignment1/GeneObject.rb' # require_relative so that the path is relative to this file

class AnnotatedGene < Gene
    
    attr_accessor :dna_seq, :prot_seq, :prot_id
    
    def initialize(params = {})
        super
        @dna_seq = params.fetch(:dna_seq, nil)
        @prot_seq = params.fetch(:prot_seq, nil)
        @prot_id = params.fetch(:prot_id, nil)
    end
end