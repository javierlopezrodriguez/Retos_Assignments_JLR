require 'rgl/adjacency'
require 'rgl/connected_components'

graph = RGL::AdjacencyGraph.new
graph.add_edge(:a1, :a2)
graph.add_edge(:a2, :a3)
graph.add_edge(:a4, :a5)
graph.add_edge(:a6, :a7)
graph.add_edge(:a1, :a2)
puts graph.vertices
puts graph.edges
puts graph.edges.class
graph.edges.each do |edge|
    puts edge.class

    puts edge.to_a
    puts edge.to_s
end
graph.each_connected_component do |subgraph|
    puts "bla"
    puts subgraph
    puts subgraph.class
    subgraph.each do |node|
        puts node
        puts node.class
    end
end

class This_is_a_test

    @@blabla = [1, 3, 5]

    def initialize
        
    end

    def self.function_test(num, list_bla = @@blabla)
        list_bla.delete(num) if list_bla.include? num
    end

    def self.print_blabla
        puts @@blabla
    end

end

puts "TEST"
This_is_a_test.print_blabla
This_is_a_test.function_test(num = 3)
This_is_a_test.print_blabla