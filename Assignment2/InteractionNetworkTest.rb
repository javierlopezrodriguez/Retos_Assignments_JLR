require 'minitest/autorun'
require_relative './InteractionNetwork.rb' # require_relative so that the path is relative to this file

# ruby InteractionNetworkTest.rb

#
# Some tests for InteractionNetwork
#
class InteractionNetworkTest < Minitest::Test


    def test_add_interaction_to_hash_class
        # to @@all_interactions
        InteractionNetwork.all_interactions = {} # emptying it at the start
        InteractionNetwork.add_interaction_to_hash(:id1, :id2) # default hash is @@all_interactions from InteractionNetwork
        result_hash = InteractionNetwork.all_interactions # after the function has been called
        #puts "class" + result_hash.to_s
        assert !result_hash.empty? && result_hash.keys.length == 2 && result_hash[:id1] == [:id2] && result_hash[:id2] == [:id1]

        InteractionNetwork.reset_all_interactions # emptying it at the end
    end

    def test_add_interaction_to_hash_other 
        # to some other hash
        interaction_hash = {} # empty hash
        InteractionNetwork.add_interaction_to_hash(:id1, :id2, int_hash = interaction_hash)
        #puts "other" + interaction_hash.to_s
        assert !interaction_hash.empty? && interaction_hash.keys.length == 2 && interaction_hash[:id1] == [:id2] && interaction_hash[:id2] == [:id1]
    end

    def test_add_interaction_to_hash_when_repeated
        # to @@all_interactions when they are already there
        InteractionNetwork.all_interactions = {id1: [:id2], id2: [:id1]} # hash with one interaction :id1 <-> :id2
        InteractionNetwork.add_interaction_to_hash(:id1, :id2) # trying to add the same interaction
        result_hash = InteractionNetwork.all_interactions # after the function has been called
        #puts "when repeated" + result_hash.to_s
        assert !result_hash.empty? && result_hash.keys.length == 2 && result_hash[:id1] == [:id2] && result_hash[:id2] == [:id1]

        InteractionNetwork.reset_all_interactions # emptying it at the end
    end

    def test_add_interaction_to_hash_multiple
        # to @@all_interactions, multiple interactions with a matching id
        InteractionNetwork.all_interactions = {} # emptying it at the start
        InteractionNetwork.add_interaction_to_hash(:id1, :id2)
        InteractionNetwork.add_interaction_to_hash(:id3, :id1)
        InteractionNetwork.add_interaction_to_hash(:id2, :id4)
        result_hash = InteractionNetwork.all_interactions # after the function has been called
        #puts "multiple" + result_hash.to_s
        assert !result_hash.empty? && result_hash.keys.length == 4 && result_hash[:id1].include?(:id2) && result_hash[:id1].include?(:id3) && result_hash[:id4] == [:id2]

        InteractionNetwork.reset_all_interactions # emptying it at the end
    end



    def test_get_interactions_from_all_interactions_exact
        # when there are just those interactions
        InteractionNetwork.all_interactions = {id1: [:id3, :id2], id2: [:id1], id3: [:id1]}
        int_hash = InteractionNetwork.get_interactions_from_all_interactions([:id1, :id2, :id3])
        all_hash = InteractionNetwork.all_interactions

        assert int_hash == all_hash && int_hash.keys.length == 3 && int_hash[:id1].include?(:id2)
        InteractionNetwork.reset_all_interactions
    end

    def test_get_interactions_from_all_interactions_more
        # when there are those interactions and more
        InteractionNetwork.all_interactions = {id1: [:id3, :id2], id2: [:id1, :id5], id3: [:id1], id4: [:id5], id5: [:id4, :id2]}
        int_hash = InteractionNetwork.get_interactions_from_all_interactions([:id1, :id2, :id3])
        all_hash = InteractionNetwork.all_interactions

        assert int_hash != all_hash && int_hash.keys.length == 3 && int_hash[:id1].include?(:id2) && int_hash[:id2] == [:id1]
        InteractionNetwork.reset_all_interactions
    end

    def test_get_interactions_from_all_interactions_none
        # when there aren't any interactions but @@all_interactions isn't empty
        InteractionNetwork.all_interactions = {id1: [:id3, :id2], id2: [:id1], id3: [:id1]}
        int_hash = InteractionNetwork.get_interactions_from_all_interactions([:id7, :id8, :id9])
        all_hash = InteractionNetwork.all_interactions

        assert int_hash != all_hash && int_hash.nil?
        InteractionNetwork.reset_all_interactions
    end

    def test_get_interactions_from_all_interactions_empty
        # when @@all_interactions is empty
        InteractionNetwork.all_interactions = {}
        int_hash = InteractionNetwork.get_interactions_from_all_interactions([:id7, :id8, :id9]) # nil
        all_hash = InteractionNetwork.all_interactions # empty hash

        assert int_hash != all_hash && int_hash.nil?
        InteractionNetwork.reset_all_interactions
    end



    def test_read_gene_list 
        # standard, every id is unique and correct
        InteractionNetwork.reset_gene_array # []
        InteractionNetwork.read_gene_list("Test_read_gene_list.txt")
        gene_array = InteractionNetwork.gene_array

        assert gene_array.length == 6 && gene_array.include?(:at5g54270)
        InteractionNetwork.reset_gene_array
    end

    def test_read_gene_list_repeated_ids_and_incorrect_ids
        # when there are repeated ids and ids what are not AGI locus codes
        InteractionNetwork.reset_gene_array # []
        InteractionNetwork.read_gene_list("Test_repeated_and_incorrect.txt")
        gene_array = InteractionNetwork.gene_array

        assert gene_array.length == 6 && gene_array.include?(:at5g54270) && !gene_array.include?(:wwwwwwwww) && gene_array == gene_array.uniq
        InteractionNetwork.reset_gene_array

    end

    def test_read_gene_list_file_not_found
        # when the file doesn't exist
        InteractionNetwork.reset_gene_array # []
        InteractionNetwork.read_gene_list("This_file_does_not_exist.txt")
        gene_array = InteractionNetwork.gene_array

        assert gene_array.empty?
        InteractionNetwork.reset_gene_array
    end



    def test_find_interactions_intact_none
        # when the gene has no interactions
        gene_id = :at4g27030
        InteractionNetwork.all_interactions = {}
        InteractionNetwork.gene_array = [gene_id]

        InteractionNetwork.find_interactions_intact
        int_hash = InteractionNetwork.all_interactions

        assert int_hash.empty? && int_hash.is_a?(Hash)

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array
    end

    ##################  THIS IS FAILING !!!! ###################
    def test_find_interactions_intact_some
        # when the gene has some interactions, including from other species
        gene_id = :at4g09650
        InteractionNetwork.all_interactions = {}
        InteractionNetwork.gene_array = [gene_id]

        InteractionNetwork.find_interactions_intact
        int_hash = InteractionNetwork.all_interactions

        assert !int_hash.empty? && int_hash.keys.include?(gene_id) && int_hash.keys.length > 1

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array
    end

    def test_find_interactions_intact_species
        # when the gene's interactions include different species
        gene_id = :at1g06680 # has no arath - arath interactions
        InteractionNetwork.all_interactions = {}
        InteractionNetwork.gene_array = [gene_id]

        InteractionNetwork.find_interactions_intact
        int_hash = InteractionNetwork.all_interactions

        assert int_hash.empty? && int_hash.is_a?(Hash)

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array
    end

    def test_find_interactions_intact_not_agi
        # when the gene is not from arabidopsis
        gene_id = :notacorrectid
        InteractionNetwork.all_interactions = {}
        InteractionNetwork.gene_array = [gene_id]

        InteractionNetwork.find_interactions_intact
        int_hash = InteractionNetwork.all_interactions

        assert int_hash.empty? && int_hash.is_a?(Hash)

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array
    end



    def test_remove_unimportant_branches_none
        # @@all_interactions not empty, but no unimportant branches
        InteractionNetwork.gene_array = [:id1, :id2]
        InteractionNetwork.all_interactions = {id1: [:idX], idX: [:id1, :id2], id2: [:idX]} 
        # id1 <-> idX <-> id2

        #puts "none prev" + InteractionNetwork.all_interactions.to_s
        InteractionNetwork.remove_unimportant_branches
        #puts "none post" + InteractionNetwork.all_interactions.to_s

        int_hash = InteractionNetwork.all_interactions
        assert !int_hash.empty? && int_hash.keys.length == 3 && int_hash[:idX] == [:id1, :id2]

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array
    end

    def test_remove_unimportant_branches_empty
        # @@all_interactions empty
        InteractionNetwork.gene_array = [:id1, :id2]
        InteractionNetwork.all_interactions = {} # empty

        #puts "empty prev" + InteractionNetwork.all_interactions.to_s
        InteractionNetwork.remove_unimportant_branches
        #puts "empty post" + InteractionNetwork.all_interactions.to_s

        int_hash = InteractionNetwork.all_interactions
        assert int_hash.empty? && int_hash.is_a?(Hash)

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array
    end

    def test_remove_unimportant_branches_one_short
        # one unimportant branch of one gene
        InteractionNetwork.gene_array = [:id1, :id2]
        InteractionNetwork.all_interactions = {id1: [:idX, :id_unimp], idX: [:id1, :id2], id2: [:idX], id_unimp: [:id1]} 
        # id1 <-> idX <-> id2 , id1 <-> id_unimp

        #puts "one short prev" + InteractionNetwork.all_interactions.to_s
        InteractionNetwork.remove_unimportant_branches
        #puts "one short post" + InteractionNetwork.all_interactions.to_s

        int_hash = InteractionNetwork.all_interactions
        assert int_hash.keys.length == 3 && int_hash[:idX] == [:id1, :id2] && !int_hash.keys.include?(:id_unimp) && int_hash[:id1] == [:idX]

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array

    end

    def test_remove_unimportant_branches_multiple
        # more than one unimportant branches of one gene
        InteractionNetwork.gene_array = [:id1, :id2]
        InteractionNetwork.all_interactions = {id1: [:idX, :id_unimp1], idX: [:id1, :id2], id2: [:idX, :id_unimp2], id_unimp1: [:id1], id_unimp2: [:id2]} 
        # id1 <-> idX <-> id2 , id1 <-> id_unimp1 , id2 <-> id_unimp2

        #puts "multiple prev" + InteractionNetwork.all_interactions.to_s
        InteractionNetwork.remove_unimportant_branches
        #puts "multiple post" + InteractionNetwork.all_interactions.to_s

        int_hash = InteractionNetwork.all_interactions
        assert int_hash.keys.length == 3 && !int_hash.keys.include?(:id_unimp1) && !int_hash.keys.include?(:id_unimp2) && int_hash[:id1] == [:idX] && int_hash[:id2] == [:idX]

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array

    end

    def test_remove_unimportant_branches_one_long
        # one unimportant branch of more than one gene
        InteractionNetwork.gene_array = [:id1, :id2]
        InteractionNetwork.all_interactions = {id1: [:idX, :unimp1], idX: [:id1, :id2], id2: [:idX], unimp1: [:id1, :unimp2], unimp2: [:unimp1, :unimp3], unimp3: [:unimp2]} 
        # id1 <-> idX <-> id2 , id1 <-> unimp1 <-> unimp2 <-> unimp3

        #puts "one long prev" + InteractionNetwork.all_interactions.to_s
        InteractionNetwork.remove_unimportant_branches
        #puts "one long post" + InteractionNetwork.all_interactions.to_s

        int_hash = InteractionNetwork.all_interactions
        assert int_hash.keys.length == 3 && !int_hash.keys.include?(:unimp1) && !int_hash.keys.include?(:unimp2) && !int_hash.keys.include?(:unimp3) && int_hash[:id1] == [:idX] && int_hash[:id2] == [:idX]

        InteractionNetwork.reset_all_interactions
        InteractionNetwork.reset_gene_array

    end

    def test_remove_unimportant_branches_branched
        # one unimportant branch but with many ends
        InteractionNetwork.gene_array = [:id1, :id2]
        InteractionNetwork.all_interactions = {}
        # id1 <-> idX <-> id2 <-> idA <-> idB, idB <-> idB1, idB <-> idB2, idB <-> idB3
        [[:id1, :idX], [:idX, :id2], [:id2, :idA], [:idA, :idB], [:idB, :idB1], [:idB, :idB2], [:idB, :idB3]].each do |pair|
            InteractionNetwork.add_interaction_to_hash(*pair)
        end
        #puts "branched before" + InteractionNetwork.all_interactions.to_s
        InteractionNetwork.remove_unimportant_branches
        #puts "branched after" + InteractionNetwork.all_interactions.to_s

        int_hash = InteractionNetwork.all_interactions
        assert int_hash.keys.length == 3 && !int_hash.keys.include?(:idB) && !int_hash.keys.include?(:idB1) && !int_hash.keys.include?(:idB2) && !int_hash.keys.include?(:idB3)
    end

end