class Annotation

    # General use Annotation object

    # Attributes:
    # @annotations_hash: a hash that, for each annotation type (key), contains an array of arrays
    # (there could be multiple annotations of the same type)
    # example: @annotations_hash["GO"] could contain [["GO:0005634", "C:nucleus", "IEA:UniProtKB-SubCell"], ["GO:0000151", "C:ubiquitin ligase complex", "IBA:GO_Central"]]
    
    # Only adding a reader so that the annotations get added via the functions defined below
    attr_reader :annotations_hash

    # on initialization the hash is empty
    def initialize
        @annotations_hash = {}
    end

    # Function to add one annotation
    def add_one_annotation(key, values)
        unless @annotations_hash.key?(key)
            @annotations_hash[key] = [] # empty array if there isn't any with that key
        end
        @annotations_hash[key] << values # appending values to the empty array
        # if values is only one element, we will have [a, b, c, ...]
        # if values is an array, we will have [[a1, a2], [b1, b2], ...]
    end

    # Function to add multiple annotations
    def add_multiple_annotations(key, array_of_values)
        # for each values (array or single element) in array_of_values
        array_of_values.each do |values|
            add_one_annotation(key, values)
        end
    end
end