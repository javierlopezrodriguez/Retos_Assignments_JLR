require 'minitest/autorun'
require_relative './Annotation.rb' # require_relative so that the path is relative to this file

# ruby AnnotationTest.rb

class AnnotationTest < Minitest::Test
  
    def test_annotate_single_value
        ann = Annotation.new
        ann.add_one_annotation("A", "test")
        ann_hash = ann.annotations_hash
        #puts ann_hash

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0] == "test" && !ann_hash["A"][0].is_a?(Array)
    end

    def test_annotate_single_array
        ann = Annotation.new
        ann.add_one_annotation("A", ["test1", "test2"])
        ann_hash = ann.annotations_hash
        #puts ann_hash

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0].is_a?(Array) && ann_hash["A"][0][0] == "test1"
    end

    def test_annotate_multiple_values
        ann = Annotation.new
        ann.add_multiple_annotations("A", ["ann1", "ann2", "ann3"])
        ann_hash = ann.annotations_hash
        #puts ann_hash

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][2] == "ann3" && !ann_hash["A"][0].is_a?(Array)
    end

    def test_annotate_multiple_arrays
        ann = Annotation.new
        ann.add_multiple_annotations("A", [["ann1_first", "ann1_second"], ["ann2_first", "ann2_second"]])
        ann_hash = ann.annotations_hash
        #puts ann_hash

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0].is_a?(Array) 
    end
end