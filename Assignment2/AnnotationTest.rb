require 'minitest/autorun'
require_relative './Annotation.rb' # require_relative so that the path is relative to this file

# ruby AnnotationTest.rb

class AnnotationTest < Minitest::Test

    # Testing basic behaviours when @annotations_hash[key] is an array:
  
    def test_annotate_array_single_value
        ann = Annotation.new
        ann.add_one_annotation_as_array("A", "test")
        ann_hash = ann.annotations_hash
        #puts ann_hash
        # should be: {"A" => ["test"]}

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0] == "test" && !ann_hash["A"][0].is_a?(Array)
    end

    def test_annotate_array_single_array
        ann = Annotation.new
        ann.add_one_annotation_as_array("A", ["test1", "test2"])
        ann_hash = ann.annotations_hash
        #puts ann_hash
        # should be: {"A" => ["test1", "test2"]}

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0].is_a?(Array) && ann_hash["A"][0][0] == "test1"
    end

    def test_annotate_array_multiple_values
        ann = Annotation.new
        ["ann1", "ann2", "ann3"].each {|ann_value| ann.add_one_annotation_as_array("A", ann_value)}
        ann_hash = ann.annotations_hash
        #puts ann_hash
        # should be: {"A" => ["ann1", "ann2", "ann3"]}

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][2] == "ann3" && !ann_hash["A"][0].is_a?(Array)
    end

    def test_annotate_array_multiple_arrays
        ann = Annotation.new
        [["ann1_first", "ann1_second"], ["ann2_first", "ann2_second"]].each {|ann_array| ann.add_one_annotation_as_array("A", ann_array)}
        ann_hash = ann.annotations_hash
        #puts ann_hash
        # should be: {"A" => [["ann1_first", "ann1_second"], ["ann2_first", "ann2_second"]]}

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0].is_a?(Array) 
    end

    def test_annotate_array_repeated_multiple_arrays
        ann = Annotation.new
        [["A", "B"], ["A", "A"], ["B", "B"], ["A"], ["B"], ["A"], ["B"], ["A", "B", "B"], ["A", "B", "C"], ["A", "B"]].each do |ann_array|
            ann.add_one_annotation_as_array(:A, ann_array)
        end
        ann_hash = ann.annotations_hash
        # should be: {A: [["A", "B"], ["A", "A"], ["B", "B"], ["A"], ["B"], ["A", "B", "B"], ["A", "B", "C"]]}
        ann_array = ann_hash[:A]
        #puts ann_array.to_s
        assert ann_array.length == 7 && ann_array[3] == ["A"] && ann_array[4] == ["B"] && ann_array[5] == ["A", "B", "B"] && ann_array[6] == ["A", "B", "C"]
    end

    def test_annotate_array_when_already_has_hash
        ann = Annotation.new
        ann.annotations_hash["A"] = {} # empty hash
        ann.add_one_annotation_as_array("A", ["B1", "B2"]) # should print a warning and not do anything
        ann_hash = ann.annotations_hash
        # should be: {"A" => {}}

        # Checking that it is still a hash and hasn't introduced anything
        assert ann_hash["A"].is_a?(Hash) && !ann_hash["A"].is_a?(Array) && ann_hash["A"].empty?
    end

    # Testing basic behaviours when @annotations_hash[key] is a hash:

    def test_annotate_hash_when_already_has_array
        ann = Annotation.new
        ann.annotations_hash["A"] = [] # empty array
        ann.add_one_annotation_as_hash("A", {B1: "B2"}) # should print a warning and not do anything
        ann_hash = ann.annotations_hash
        # should be: {"A" => []}

        # Checking that it is still an array and hasn't introduced anything
        assert !ann_hash["A"].is_a?(Hash) && ann_hash["A"].is_a?(Array) && ann_hash["A"].empty?
    end

    def test_annotate_hash
        ann = Annotation.new
        ann.add_one_annotation_as_hash("A", {bkey: :bvalue})
        ann_hash = ann.annotations_hash
        #puts ann_hash
        # should be: {"A" => {bkey: :bvalue}}

        assert ann_hash.key?("A") && ann_hash["A"].key?(:bkey) && ann_hash["A"].keys.length == 1 && ann_hash["A"][:bkey] == :bvalue
    end

    def test_annotate_hash_diff_key
        ann = Annotation.new
        ann.add_one_annotation_as_hash("A", {bkey: :bvalue})
        ann.add_one_annotation_as_hash("A", {otherkey: :othervalue})
        ann_hash = ann.annotations_hash
        # should be: {"A" => {bkey: :bvalue, otherkey: :othervalue}}

        assert ann_hash.key?("A") && ann_hash["A"].key?(:bkey) && ann_hash["A"].key?(:otherkey) && ann_hash["A"].keys.length == 2 && ann_hash["A"][:bkey] == :bvalue && ann_hash["A"][:otherkey] == :othervalue
    end

    def test_annotate_hash_multiple_same_key_same_value
        ann = Annotation.new
        ann.add_one_annotation_as_hash("A", {bkey: :bvalue})
        ann.add_one_annotation_as_hash("A", {bkey: :bvalue}) # should not do anything because it is already there
        ann_hash = ann.annotations_hash
        # should be: {"A" => {bkey: :bvalue}}

        assert ann_hash.key?("A") && ann_hash["A"].key?(:bkey) && ann_hash["A"].keys.length == 1 && ann_hash["A"][:bkey] == :bvalue && ann_hash["A"].values.length == 1
    end

    def test_annotate_hash_multiple_same_key_diff_value
        ann = Annotation.new
        ann.add_one_annotation_as_hash("A", {bkey: :bvalue})
        ann.add_one_annotation_as_hash("A", {bkey: :different_value}) # should print a warning and not do anything
        ann_hash = ann.annotations_hash
        # should be: {"A" => {bkey: :bvalue}}

        assert ann_hash.key?("A") && ann_hash["A"].key?(:bkey) && ann_hash["A"].keys.length == 1 && ann_hash["A"][:bkey] == :bvalue && ann_hash["A"].values.length == 1
    end

    # Testing KEGG and GO anotations:

    def test_kegg
        gene_id = :at1g74960
        ann = Annotation.new
        ann.get_kegg_annotation(gene_id)
        ann_hash = ann.annotations_hash
        # {"ath00061"=>"Fatty acid biosynthesis", "ath00780"=>"Biotin metabolism", "ath01100"=>"Metabolic pathways", "ath01212"=>"Fatty acid metabolism", "ath01240"=>"Biosynthesis of cofactors"}
        assert ann_hash[:KEGG].is_a?(Hash) && ann_hash[:KEGG].keys.length == 5 && ann_hash[:KEGG]["ath00061"] == "Fatty acid biosynthesis" && ann_hash[:KEGG]["ath01240"] == "Biosynthesis of cofactors"
    end

    def test_kegg_empty
        gene_id = :at4g18960 # this has no KEGG pathways (at 2021-10-24)
        ann = Annotation.new
        ann.get_kegg_annotation(gene_id)
        ann_hash = ann.annotations_hash
        # ann_hash[:KEGG] should be nil
        assert ann_hash[:KEGG].nil?
    end

    def test_go
        gene_id = :at1g74960
        ann = Annotation.new
        ann.get_go_annotation(gene_id)
        ann_hash = ann.annotations_hash
        #puts ann_hash
        # {"GO:0009631"=>"cold acclimation", "GO:0009793"=>"embryo development ending in seed dormancy", "GO:0006633"=>"fatty acid biosynthetic process"}
        assert ann_hash[:GO].is_a?(Hash) && ann_hash[:GO].keys.length == 3 && ann_hash[:GO]["GO:0009631"] == "cold acclimation"
    end

end