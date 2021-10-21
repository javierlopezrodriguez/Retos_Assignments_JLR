require 'minitest/autorun'
require_relative './Annotation.rb' # require_relative so that the path is relative to this file

# ruby AnnotationTest.rb

class AnnotationTest < Minitest::Test
  
    def test_annotate_single_value
        ann = Annotation.new
        ann.add_one_annotation("A", "test")
        ann_hash = ann.annotations_hash

        assert ann_hash.key?("A") && ann_hash["A"].is_a?(Array) && ann_hash["A"][0] == "test" && !(ann_hash["A"][0].is_a? Array)
    end

    def test_annotate_single_array

    end

    def test_annotate_multiple_values

    end

    def test_annotate_multiple_arrays

    end

end