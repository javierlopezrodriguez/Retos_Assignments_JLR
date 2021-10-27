require 'minitest/autorun'
require_relative './InteractionNetwork.rb' # require_relative so that the path is relative to this file

# ruby InteractionNetworkTest.rb

class InteractionNetworkTest < Minitest::Test


    def test_add_interaction_to_hash_class
        # to @@all_interactions
        
    end

    def test_add_interaction_to_hash_other 
        # to some other hash

    end

    def test_add_interaction_to_hash_class_repeated
        # to @@all_interactions when they are already there
        
    end



    def test_get_interactions_from_all_interactions_exact
        # when there are just those interactions

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

## QUEDAN MAS, REMOVE UNIMPORTANT INTERACTIONS!







    








end