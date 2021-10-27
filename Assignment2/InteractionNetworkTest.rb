require 'minitest/autorun'
require_relative './InteractionNetwork.rb' # require_relative so that the path is relative to this file

# ruby InteractionNetworkTest.rb

class InteractionNetworkTest < Minitest::Test


    def test_add_interaction_to_hash_class
        # to @@all_interactions
        InteractionNetwork.all_interactions = {} # emptying it at the start
        InteractionNetwork.add_interaction_to_hash(:id1, :id2) # default hash is @@all_interactions from InteractionNetwork
        result_hash = InteractionNetwork.all_interactions # after the function has been called

        assert !result_hash.empty? && result_hash.keys.length == 2 && result_hash[:id1] == [:id2] && result_hash[:id2] == [:id1]

        InteractionNetwork.all_interactions = {} # emptying it at the end
    end

    def test_add_interaction_to_hash_other 
        # to some other hash
        interaction_hash = {} # empty hash
        InteractionNetwork.add_interaction_to_hash(:id1, :id2, int_hash = interaction_hash)
        
        assert !interaction_hash.empty? && interaction_hash.keys.length == 2 && interaction_hash[:id1] == [:id2] && interaction_hash[:id2] == [:id1]
    end

    def test_add_interaction_to_hash_when_repeated
        # to @@all_interactions when they are already there
        InteractionNetwork.all_interactions = {id1: [:id2], id2: [:id1]} # hash with one interaction :id1 <-> :id2
        InteractionNetwork.add_interaction_to_hash(:id1, :id2) # trying to add the same interaction
        result_hash = InteractionNetwork.all_interactions # after the function has been called

        assert !result_hash.empty? && result_hash.keys.length == 2 && result_hash[:id1] == [:id2] && result_hash[:id2] == [:id1]

        InteractionNetwork.all_interactions = {} # emptying it at the end
    end

    def test_add_interaction_to_hash_multiple
        # to @@all_interactions, multiple interactions with a matching id
        InteractionNetwork.all_interactions = {} # emptying it at the start
        InteractionNetwork.add_interaction_to_hash(:id1, :id2)
        InteractionNetwork.add_interaction_to_hash(:id3, :id1)
        InteractionNetwork.add_interaction_to_hash(:id2, :id4)
        result_hash = InteractionNetwork.all_interactions # after the function has been called

        assert !result_hash.empty? && result_hash.keys.length == 4 && result_hash[:id1].include?(:id2) && result_hash[:id1].include?(:id3) && result_hash[:id4] == [:id2]

        InteractionNetwork.all_interactions = {} # emptying it at the end
    end



    def test_get_interactions_from_all_interactions_exact
        # when there are just those interactions

        InteractionNetwork.all_interactions = {}

    end

    def test_get_interactions_from_all_interactions_more
        # when there are those interactions and more

    end

    def test_get_interactions_from_all_interactions_none
        # when there aren't any interactions but @@all_interactions isn't empty

    end

    def test_get_interactions_from_all_interactions_empty
        # when @@all_interactions is empty

    end



    def test_read_gene_list 
        # standard, every id is unique and correct

    end

    def test_read_gene_list_repeated_ids_and_incorrect_ids
        # when there are repeated ids and ids what are not AGI locus codes

    end

    def test_read_gene_list_file_not_found
        # when the file doesn't exist

    end

################### I'm pretty confident the following one works fine:
################### LEAVE IT FOR LAST

    def find_interactions_intact_none
        # when the gene has no interactions

    end

    def find_interactions_intact_some
        # when the gene has some interactions, including from other species

    end

    def find_interactions_intact_species
        # when the gene has some interactions and they include different species
        :at1g06680
    end

    def find_interactions_intact_not_agi
        # when the gene is not from arabidopsis

    end

####################

## ESTAS SON IMPORTANTES, MÍRALAS!

    def test_remove_unimportant_interactions
        # when there are interactions to be removed
    end

    def test_remove_unimportant_interactions_none
        # when there aren't interactions to be removed
    end

    def test_remove_unimportant_interactions_empty
        # when @@all_interactions is empty
    end

end