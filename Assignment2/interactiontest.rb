# for InteractionNetwork.rb, attempt without rgl

    #def self.create_networks()
        # for each gene in the gene list:
            # get all the interactions
            # mark that gene as completed or something
            # remove the genes that are already completed from the interactions
            # if any interaction:
                # check which genes are in the gene list:
                    # add those interactions to the network or to the intermediate thing (maybe create an interaction object or something?? idk)
                    # (an interaction added to the network, direct or with intermediates, needs that both the start and end are genes from the gene list (intermediates can be or not be))
                # for each gene in the interactions:
                    # get all the interactions
                    # mark that gene as completed or something
                    # remove the genes that are already completed from the interactions
                    # if any interaction:
                        # check which genes are in the gene list:
                            # add those interactions to the network or to the intermediate thing

                            # NOT FINISHED

                            # probably could add recursion here somewhere

        # MIRA STRUCTS PARA NO ESTAR REBUSCANDO MIL VECES SI TAL SYMBOL ESTA EN LA GENELIST O NO!! en plan structs para usar aqui simplemente, cuando haces la lista de los genes etc. i guess
        # a lo mejor no tiene sentido eh 

    #end

=begin     
    def self.create_networks()
        # creating a hash to store the genes as I go through them
        total_genes = {}
        @@gene_array.each do |gene|

        end

        # better:::
        start_genes = @@all_interactions.keys.select {|gene_id| @@gene_array.include? gene_id} # genes from @@gene_array that have interactions
        start_genes.each do |gene1|

        end

        # for each gene in @@gene_array (from our .txt gene list)
        @@gene_array.each do |gene1|
            successful? = false # boolean value, it is true when the network contains two or more genes that come from @@gene_array
            # hash to store the genes of the current network, their interactions, and if they're part of @@gene_array or not
            network_genes = {}
            # updating the entry at the hash, it has been visited (now) and is part of @@gene_array
            total_genes[gene1] = {visited?: true, in_gene_list?: true}
            # getting its interactions
            gene1_inter = @@all_interactions[gene1]
            # if there are interactions (not nil)
            if gene1_inter
                # adding the gene to the network_genes hash
                network_genes[gene1] = {in_gene_list?: true, interactions: []} # gene1 comes from @@gene_array
                # for each interaction
                gene1_inter.each do |gene2|
                    # if gene2 is in the hash already (not nil)
                    if total_genes[gene2]
                        next if total_genes[gene2][:visited?] # next if gene2 has been visited already
                        # if it exists in the hash but hasn't been visited yet
                        total_genes[gene2][:visited?] = true # setting it as visited
                        in_gene_list = total_genes[gene2][:in_gene_list?] # true if it is part of @@gene_array
                        successful? = successful? || in_gene_list # true if it was already true or if the gene2 is part of @@gene_array
                        # adding gene2 to the network_genes if it wasn't there
                        network_genes[gene2] = {in_gene_list?: in_gene_list, interactions: []} if network_genes[gene2].nil?
                        # adding gene1 as an interaction of gene2 if it wasn't already there
                        network_genes[gene2][:interactions] |= gene1
                        # adding gene2 as an interaction of gene1 if it wasn't already there
                        network_genes[gene1][:interactions] |= gene2

                        # problem! now if gene1-gene2 and gene2-gene3-gene4, how do I keep track of this

                    else

                    end
                end
            end
            
            # if there is more than one gene from @@gene_array, create the InteractionNetwork object
        end
    end 
=end



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


