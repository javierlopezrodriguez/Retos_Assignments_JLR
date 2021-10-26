require_relative './Annotation.rb' # require_relative so that the path is relative to this file
# I'm using the rgl gem, version 0.5.7
require 'rgl/adjacency' 
require 'rgl/connected_components'

class InteractionNetwork < Annotation

    # It inherits @annotations_hash, its attr_reader, and the methods add_one_annotation and add_multiple_annotations from Annotation

    @@all_networks = [] # array to store every InteractionNetwork object

    @@all_interactions = {} # hash to store every interaction found that involves one of the genes read from the file
    # gene1: [array of genes interacting with gene1]
    # To simplify searches, I'm duplicating information in favour of reducing time spent iterating through arrays:
    # if gene1 interacts with gene2, im storing both gene1->gene2 and gene2->gene1 interactions.
    # this way, when I want the genes that interact with gene1, I just do @@all_interactions[gene1], 
    # and don't have to search through the values arrays.

    @@gene_array = [] # array to store every gene id (as a lowercase symbol) read from the .txt file

    attr_accessor :network_graph # Graph that represents an Interaction Network

    def initialize(params = {})
        super # initializing Annotation
        # initializing @network_graph with a new AdjacencyGraph (undirected graph from rgl)
        @network_graph = RGL::AdjacencyGraph.new
        # getting the hash with the network interactions
        net_interactions = params.fetch(:net_interactions, {})
        # adding each interaction to the graph:
        net_interactions.each do |gene_id, interactions|
            next if interactions.empty? # skip if there aren't interactions (shouldn't happen)
            # for each id in the interactions array
            interactions.each do |inter_id|
                @network_graph.add_edge(gene_id, inter_id) # adding the edge to the graph
            end
        end
        # getting the list of genes from the graph
        network_gene_list = @network_graph.vertices
        # adding KEGG annotations for the genes in the network
        InteractionNetwork.get_kegg_annotation(network_gene_list)
        # adding GO annotations for the genes in the network
        InteractionNetwork.get_go_annotation(network_gene_list)
        # adding this new InteractionNetwork object into the class variable @all_networks
        @@all_networks << self 
    end

    # Class methods:

    def self.add_interaction_to_hash(gene1, gene2, int_hash = @@all_interactions)
        # Class method
        # adds interactions gene1->gene2 and gene2->gene1 to a hash, by default @@all_interactions
        [gene1.to_sym, gene2.to_sym].each { |gene| 
            # for each gene, creating an empty array to store the gene's interactions if there aren't any already
            int_hash[gene] = [] unless int_hash.key?(gene1) 
        }
        int_hash[gene1] |= [gene2] # adding gene2 to gene1's interaction array if it isn't already there
        int_hash[gene2] |= [gene1] # adding gene1 to gene2's interaction array if it isn't already there
    end

    def self.get_interactions_from_all_interactions(id_list)
        # Class method
        # gets the interactions A-B from @@all_interactions where both A and B are part of id_list
        int_subset = {} # hash to store the results
        # for each unique id
        id_list.uniq.each do |id|
            int_subset[id] = [] # empty array for id
            @@all_interactions[id].each do |int_id| # for each int_id interacting with id
                if id_list.contains?(int_id) # if int_id is part of the id_list, there is an interaction between two members of the list
                    int_subset[id] |= [int_id] # adding int_id to the array of id if it's not already there
                    int_subset[int_id] = [] unless int_subset.key?(int_id) # creating an array for int_id if it doesn't exist
                    int_subset[int_id] |= [id] # adding id to the array of int_id if it's not already there
                end
            end
        end
        return int_subset unless int_subset.empty? # returns the results hash
        return nil # if empty
    end

    def self.read_gene_list(filename)
        # Class method
        # for each gene in the file, stores the id as a lowercase symbol in @@gene_array (if it doesn't exist already)
        IO.foreach(filename) do |gene|
            gene = gene.strip.downcase # removing whitespace (if any) and converting the letters to lowercase
            @@gene_array |= [gene.to_sym] if gene =~ /at\wg\d\d\d\d\d/ # storing the gene id as a symbol if it matches the regexp
        end
    end

    # For genes A, B in the gene list, I will consider A-B interactions, and A-X-B interactions, where X is not part of the gene list.
    def self.find_interactions_intact(cutoff = 0.45)
        @@gene_array.each do |gene_id|
            next unless gene_id =~ /[Aa][Tt]\w[Gg]\d\d\d\d\d/ # we only want AGI locus codes
            url = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene_id}?format=tab25"
            response = InteractionNetwork.fetch(url)
            if response && !response.body.empty? # ruby uses short-circuit evaluation, if response is false, the second half doesn't get evaluated
                response.body.each_line do |tab25|
                    fields = tab25.split("\t")
                    # fields 4 and 5 contain the interacting genes, fields 9 and 10 contain the species, fields 14 contains the mi-score
                    # Checking for species, taxid:3702 is Arabidopsis thaliana
                    next unless fields[9] =~ /taxid:3702/ && fields[10] =~ /taxid:3702/ 
                    # Checking for score >= cutoff
                    # http://europepmc.org/article/MED/25652942
                    # "the IntAct database regards data with a score of >0.6 as high-confidence and 0.45–0.6 as medium confidence" 
                    matchscore = fields[14].match(/score:(.*)/)
                    next unless matchscore # if there is no score, skip
                    miscore = matchscore[1].to_f
                    next unless miscore >= cutoff
                    # Getting the genes and checking they are in AGI locus code format:
                    matchgene1 = fields[4].match(/uniprotkb:([Aa][Tt]\w[Gg]\d\d\d\d\d)/)
                    matchgene2 = fields[5].match(/uniprotkb:([Aa][Tt]\w[Gg]\d\d\d\d\d)/)
                    next unless matchgene1 && matchgene2 # skipping if there aren't AGI locus codes
                    gene1, gene2 = matchgene1[1].downcase.to_sym, matchgene2[1].downcase.to_sym
                    next if gene1 == gene2 # if both are the same gene, skip
                    new_gene = gene1 if gene2 == gene_id # if the original gene_id used in the search is gene2, the new gene is gene1
                    new_gene = gene2 if gene1 == gene_id # and viceversa
                    next unless gene2 == gene_id || gene1 == gene_id # shouldn't happen but just in case none of the genes equal the original gene_id, skip it
                    InteractionNetwork.add_interaction_to_hash(gene_id, new_gene) # adding the interaction
                end
            end
        end
    end

    # Because I am only considering A-B and A-X-B interactions (where A and B in the .txt file, X not in the file)
    # If a gene that is not in the file (not in @@gene_array) only has one interaction, it can't be part of a network
    # (because X, in the case of A-X-B, is the bridge between A and B and therefore interacts with both A and B)
    # This function does that. For each gene that is not in @@gene_array, it removes them from @@all_interactions 
    # if they interact with one gene.
    def self.remove_unimportant_interactions()
        # getting the ids in @@all_interactions that aren't part of @@gene_array
        genes_not_in_array = @@all_interactions.keys.select {|gene_id| !@@gene_array.include? gene_id }
        genes_not_in_array.each do |gene_id|
            next unless @@all_interactions[gene_id].length == 1 # skip it unless it has only one interaction
            # remove it if it only has one interaction:
            interactor = @@all_interactions[gene_id][0] # getting the id of the gene that interacts with it
            @@all_interactions.delete(gene_id) # deleting the entry of gene_id
            if @@all_interactions[interactor].length == 1 # deleting the entry of interactor if gene_id was the only element
                @@all_interactions.delete(interactor)
            else # removing gene_id from the entry of interactor if it is not the only element
                @@all_interactions[interactor].delete(gene_id)
            end
        end
    end

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


    def self.create_networks_rgl()
        # The general idea is to create an undirected graph, using all the interactions in @@all_interactions as its edges.
        # The nodes of the graph will be the genes.

        # After creating the graph, rgl can get the connected components of a graph. 
        # A connected component is a group of nodes where you can find a path between any two nodes of the group,
        # but there is no path between any node of the group and any node outside of the group.
        # (So, every smaller sub-graph that is isolated from the rest of the nodes).
        # Each connected component that contains more than one gene from the @@gene_array (our .txt) will be used to create an InteractionNetwork.

        # All the information about using this library was gotten from https://www.rubydoc.info/github/monora/rgl

        # First step: creating the graph with all of the interactions.
        full_graph = RGL::AdjacencyGraph.new # instantiating an undirected graph
        # for each gene_id in @@all_interactions hash
        @@all_interactions.each do |gene_id, interactions|
            next if interactions.empty? # skip if there aren't interactions (shouldn't happen)
            # for each id in the interactions array
            interactions.each do |inter_id|
                full_graph.add_edge(gene_id, inter_id) # adding the edge to the graph
            end
        end
        # Second step: when the graph is complete, getting each of the connected components.
        # each_connected_component returns an array with the nodes of each subgraph
        full_graph.each_connected_component do |subgraph_nodes|
            num_genes_in_array = 0 # counter, number of genes that are part of @@gene_array
            # for each node in the connected component
            subgraph_nodes.each do |node|
                num_genes_in_array += 1 if @@gene_array.include? node # incrementing the counter if the node is part of the array
            end
            # if there are two or more genes from @@gene_array, build an InteractionNetwork
            if num_genes_in_array >= 2



                # COMPLETE

                # building the interaction network? do I use a graph? seems like the best idea la verdad
                # luego para el transversal me cojo todos los edges y palante y 0 dramas

                # COMPLETE



            end
        end
    end

    # Instance methods:

    def genes
        return @network_graph.vertices
    end

    def interactions
        all_edges = @network_graph.edges
        interaction_array = []
        all_edges.each do |edge|
            interaction_array << edge.to_a
            # .to_a converts an Edge object to an array [source, target]
        end
        return interaction_array
    end

    def interactions_as_hash
        interaction_array = self.interactions
        interaction_hash = {}
        interaction_array.each do |interaction|
            gene1, gene2 = *interaction
            InteractionNetwork.add_interaction_to_hash(gene1, gene2, hash=interaction_hash)
        end
        return interaction_hash
    end

    def interactions_as_edges
        return @network_graph.edges
    end







        





    

end