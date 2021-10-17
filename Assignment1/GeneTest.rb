# https://semaphoreci.com/community/tutorials/getting-started-with-minitest
require 'minitest/autorun'
require_relative './GeneObject.rb' # require_relative so that the path is relative to this file

# ruby GeneTest.rb

class GeneTest < Minitest::Test
  
    # Testing that Gene.fabricate prints a warning message and returns nil when the gene id is incorrect.
    
    def test_fabricate_correct_id
      
      # Testing an id with the correct format
       correct_id = "AT4G11111"
       new_gene = Gene.fabricate(params = {gene_id: correct_id}) # calling the fabricator
       
       # checking that it is not nil and the id is the correct_id
       assert !new_gene.nil? && new_gene.id == correct_id && new_gene.class == Gene
    end
    
    def test_fabricate_incorrect_id
      
        # Testing an id with the incorrect format
        incorrect_id = "WRONG ID"
        new_gene = Gene.fabricate(params = {gene_id: incorrect_id}) # calling the fabricator
        
        # checking that it is nil and not a Gene
        assert new_gene.nil? && new_gene.class != Gene
    end
    
    def test_fabricate_incorrect_default_id
      
        # Testing no id passed to the fabricator
        new_gene = Gene.fabricate() # not passing anything
        
        # checking that it is nil and not a Gene
        assert new_gene.nil? && new_gene.class != Gene
    end
end