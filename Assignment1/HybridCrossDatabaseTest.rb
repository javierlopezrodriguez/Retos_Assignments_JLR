# https://semaphoreci.com/community/tutorials/getting-started-with-minitest
require 'minitest/autorun'
require './HybridCrossDatabaseObject.rb'

# ruby HybridCrossDatabaseTest.rb

class HybridCrossDatabaseTest < Minitest::Test
    
    # Testing the method #get_object_by_id for HybridCrossDatabase (inherited from Database)
    # because it is not used by the main program
    # and it's the less straightforward one (in my opinion).
    
    def test_get_object_by_id_parent1
        
        # Testing the basic functionality, when passing only one attribute name to get_object_by_id
        
        # creating the database
        cross_db = HybridCrossDatabase.new
        # creating two HybridCross objects
        cross_A = HybridCross.new(params = {parent1: "A1", parent2: "A2"}) 
        cross_B = HybridCross.new(params = {parent1: "B1", parent2: "B2"}) 
        # putting them into the database
        cross_db.all_entries << cross_A
        cross_db.all_entries << cross_B
        
        # Looking for an object with @parent1 == "B1"
        result = cross_db.get_object_by_id(input_value = "B1", attribute_name = :parent1)
        
        # check that we have returned object cross_B
        assert result.parent1 == cross_B.parent1 && result.parent2 == cross_B.parent2
    end
    
    def test_get_object_by_id_parent1_parent2
        
        # Testing that it works correctly when passing an array of two attribute names to get_object_by_id
        
        # creating the database
        cross_db = HybridCrossDatabase.new
        # creating two HybridCross objects
        cross_A = HybridCross.new(params = {parent1: "A1", parent2: "A2"}) 
        cross_B = HybridCross.new(params = {parent1: "B1", parent2: "B2"}) 
        # putting them into the database
        cross_db.all_entries << cross_A
        cross_db.all_entries << cross_B
        
        # Looking for an object with @parent1 == "A2" or @parent2 == "A2"
        result = cross_db.get_object_by_id(input_value = "A2", attribute_name = [:parent1, :parent2])
        
        # check that we have returned object cross_A
        assert result.parent1 == cross_A.parent1 && result.parent2 == cross_A.parent2
    end
    
    def test_get_object_by_id_parent1_parent2_same_name
        
        # Testing that, when given two attribute names, it starts looking for an object with value matching the first one.
        # In this case, cross_A.parent1 == cross_B.parent2 == "name",
        # so when calling the function get_object_by_id("name", [:parent1, :parent2]) it should return cross_A.
        
        # creating the database
        cross_db = HybridCrossDatabase.new
        # creating two HybridCross objects
        cross_A = HybridCross.new(params = {parent1: "name", parent2: "A2"}) 
        cross_B = HybridCross.new(params = {parent1: "B1", parent2: "name"}) 
        # putting them into the database
        cross_db.all_entries << cross_A
        cross_db.all_entries << cross_B
        
        # Looking for an object with @parent1 == "name" or @parent2 == "name"
        result = cross_db.get_object_by_id(input_value = "name", attribute_name = [:parent1, :parent2])
        
        # check that we have returned object cross_A
        assert result.parent1 == cross_A.parent1 && result.parent2 == cross_A.parent2
    end
    
    def test_failure_empty_database
        
        # Testing that get_object_by_id returns nil when the database is empty
        
        # creating the database
        cross_db = HybridCrossDatabase.new
        # We don't put any objects into the database array
        
        # Looking for an object with @parent1 == "name" or @parent2 == "name"
        result = cross_db.get_object_by_id(input_value = "name", attribute_name = [:parent1, :parent2])
        
        # check that result is nil
        assert result.nil?
    end
    
    def test_failure_full_database
        
        # Testing that get_object_by_id returns nil when the database is not empty
        # but doesn't contain an object matching input_value
        
        # creating the database
        cross_db = HybridCrossDatabase.new
        # creating a HybridCross object
        cross_A = HybridCross.new(params = {parent1: "A1", parent2: "A2"})
        # putting it into the database
        cross_db.all_entries << cross_A
        
        # Looking for an object with @parent1 == "hello"
        result = cross_db.get_object_by_id(input_value = "hello", attribute_name = :parent1)
        
        # check that result is nil
        assert result.nil?
    end
end
