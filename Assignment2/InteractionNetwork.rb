# I'm using the rgl gem, version 0.5.7
require 'rgl/adjacency' 
require 'rgl/connected_components'
require_relative './Annotation.rb'

# == InteractionNetwork
#
# Class that represents an interaction network between genes from a list.
# Contains the functions to process the list, look for the interactions and create the individual networks.
#
# == Summary
# 
# This can be used to find interactions networks between genes from a list.
#
class InteractionNetwork < Annotation
    
    # Class variable, array to store every InteractionNetwork object
    @@all_networks = []
    
    #
    # Get the class variable @@all_networks that stores every InteractionNetwork object
    #
    # @return [Array<InteractionNetwork>] The array containing every interaction network
    #
    def self.all_networks
        return @@all_networks
    end
    
    # Class variable, array to store every gene id (as a lowercase symbol) read from the .txt file
    @@gene_array = [] 

    #
    # Get the class variable @@gene_array that stores as a lowercase symbol
    # every gene id read from a .txt file
    #
    # @return [Array<Symbol>] The array containing every gene id
    #
    def self.gene_array
        return @@gene_array
    end
    
    #
    # Resets the class variable @@gene_array to an empty state
    #
    def self.reset_gene_array
        @@gene_array = []
    end
    
    #
    # Set the class variable @@gene_array to a new value
    #
    # @param [Array<Symbol>] new_value The array of gene ids
    #
    def self.gene_array=(new_value)
        @@gene_array = new_value
    end

    # Class variable, hash that stores every interaction found that involves one of the genes read from the file
    @@all_interactions = {} 
    # gene1: [array of genes interacting with gene1]
    # To simplify searches, I'm duplicating information in favour of reducing time spent iterating through arrays:
    # if gene1 interacts with gene2, im storing both gene1->gene2 and gene2->gene1 interactions.
    # this way, when I want the genes that interact with gene1, I just do @@all_interactions[gene1], 
    # and don't have to search through the values arrays.

    #
    # Get method for the class variable @@all_interactions, 
    # that stores every interaction found that involves one of the genes read from the file
    #
    # @return [Hash] The hash containing all interactions
    #
    def self.all_interactions
        return @@all_interactions
    end
    
    #
    # Resets the class variable @@all_interactions to an empty state
    #
    def self.reset_all_interactions
        @@all_interactions = {}
    end
    
    #
    # Set the class variable @@all_interactions to a new value
    #
    # @param [Hash] new_value The hash of interactions
    #
    def self.all_interactions=(new_value)
        @@all_interactions = new_value
    end
    
    # Get/Set the graph that represents the interaction network
    # @!attribute [rw]
    # @return [RGL::AdjacencyGraph] The graph
    attr_accessor :network_graph 
    
    
    #
    # Create a new instance of InteractionNetwork
    #
    # @param [Hash] params Parameters to initialize the network
    # @option params [Hash] :net_interactions A hash with the interactions that will form the network
    #
    def initialize(params = {})
        super # initializing Annotation
        # initializing @network_graph with a new AdjacencyGraph (undirected graph from rgl)
        @network_graph = RGL::AdjacencyGraph.new
        # getting the hash with the network interactions
        net_interactions = params.fetch(:net_interactions, {})
        # adding each interaction to the graph:
        net_interactions.each do |gene_id, interactions|
            next if interactions.empty? # skip when there aren't interactions (shouldn't happen)
            # foreach id in the interactions array
            interactions.each do |inter_id|
                @network_graph.add_edge(gene_id, inter_id) # adding the edge to the graph
            end
        end
        # getting the list of genes from the graph
        network_gene_list = @network_graph.vertices
        # adding KEGG annotations for the genes in the network
        get_kegg_annotation(network_gene_list)
        # adding GO annotations for the genes in the network
        get_go_annotation(network_gene_list)
        # adding this new InteractionNetwork object into the class variable @@all_networks
        @@all_networks << self
    end

    #
    # Resets the class variables to an empty state
    # (mostly used for testing and at the start of the process)
    #
    def self.start
        @@all_networks = []
        @@all_interactions = {}
        @@gene_array = []
    end
    
    #
    # Adds an interaction to a hash.
    # The interaction gets added in both directions (gene1 => [gene2] and gene2 => [gene1])
    #
    # @param [Symbol] gene1 The id of the first gene
    # @param [Symbol] gene2 The id of the second gene
    # @param [Hash] int_hash The hash to which the interactions will be added, by default the class variable @@all_interactions
    #
    def self.add_interaction_to_hash(gene1, gene2, int_hash = @@all_interactions)
        [gene1.to_sym, gene2.to_sym].each { |gene| 
            # for each gene, creating an empty array to store the gene's interactions if there aren't any already
            int_hash[gene] = [] unless int_hash.key?(gene) 
        }
        int_hash[gene1] |= [gene2] # adding gene2 to gene1's interaction array if it isn't already there
        int_hash[gene2] |= [gene1] # adding gene1 to gene2's interaction array if it isn't already there
    end
    
    #
    # Given a list of ids, returns the interactions from @@all_interactions
    # composed only by genes from the list of ids
    # (both members of the interaction need to be in the list)
    #
    # @param [Array<Symbol>] id_list The array of ids whose interactions will be returned
    #
    # @return [Hash, nil] The hash of interactions, or nil if none were found
    #
    def self.get_interactions_from_all_interactions(id_list)
        # gets the interactions A-B from @@all_interactions where both A and B are part of id_list
        int_subset = {} # hash to store the results
        # getting all the keys from id_list that are in @@all_interactions
        key_list = @@all_interactions.keys.select {|gene_id| id_list.include? gene_id}
        # for each key
        key_list.each do |key|
            # storing the interactions between the genes of the id_list
            int_subset[key] = @@all_interactions[key].select {|interactor| id_list.include? interactor}
        end
        return int_subset unless int_subset.empty? # returns the results hash
        return nil # if empty
    end
    
    #
    # Reads a file containing one gene id (in AGI locus code format) in each column
    # and stores each id as a lowercase symbol on the class variable @@gene_array
    #
    # @param [String] filename Path of the txt file
    #
    def self.read_gene_list(filename)
        # for each gene in the file, stores the id as a lowercase symbol in @@gene_array (if it doesn't exist already)
        puts "Reading the gene list..."
        begin
            IO.foreach(filename) do |gene|
                gene = gene.strip.downcase # removing whitespace (if any) and converting the letters to lowercase
                @@gene_array |= [gene.to_sym] if gene =~ /at\wg\d\d\d\d\d/ # storing the gene id as a symbol if it matches the regexp
            end
        rescue Errno::ENOENT => e # handling the missing file exception
            puts "ERROR: Can't find the file"
            $stderr.puts e.inspect
        rescue Exception => e # other possible exceptions
            $stderr.puts e.inspect
        end
    end
    
    
    # For genes A, B in the gene list, I will consider A-B interactions, and A-X-B interactions, where X is not part of the gene list.
    
    # Because I am only considering A-B and A-X-B interactions (where A and B in the .txt file, X not in the file)
    # If a gene that is not in the file (not in @@gene_array) only has one interaction, it can't be part of a network
    # (because X, in the case of A-X-B, is the bridge between A and B and therefore interacts with both A and B)

    
    #
    # Removes an id from @@all_interactions, removing it from every interaction it was part of
    #
    # @param [Symbol] gene_id The id that will be removed
    #
    # @return [Array<Symbol>, nil] The ids of the genes that interacted with gene_id, or nil if none.
    #
    def self.remove_interactions(gene_id)
        return nil if @@all_interactions.empty? || !@@all_interactions.keys.include?(gene_id) # if there aren't interactions with that id
        interactor_ids = @@all_interactions[gene_id] # storing the interactors
        @@all_interactions.delete(gene_id) # deleting the entry of gene_id
        interactor_ids.each do |interactor|
            if @@all_interactions[interactor].length == 1 # deleting the entry of interactor if gene_id was the only element
                @@all_interactions.delete(interactor)
            else # removing gene_id from the entry of interactor if it is not the only element
                @@all_interactions[interactor].delete(gene_id)
            end
        end
        return interactor_ids # returns the removed interactor ids
    end

    #
    # For every gene from @@all_interactions that is not in @@gene_array,
    # removes that gene from @@all_interactions if it only interacts with one other gene,
    # doing it iteratively until every gene matching that condition has been removed
    #
    def self.remove_unimportant_branches
        # getting the ids in @@all_interactions that aren't part of @@gene_array
        genes_not_in_array = @@all_interactions.keys.select {|gene_id| !@@gene_array.include? gene_id }
        genes_not_in_array.each do |gene_id|
            next unless @@all_interactions[gene_id].length == 1 # skip it unless it has only one interaction
            to_be_removed = gene_id
            while true
                interactors = InteractionNetwork.remove_interactions(to_be_removed) # remove to_be_removed from the @@all_interactions
                if interactors.length == 1
                    if @@gene_array.include? interactors[0]
                        break # exit the while loop if the interactor is in @@gene_array
                    else
                        # exit the while loop unless the interactor has exactly one interaction remaining
                        break if @@all_interactions[interactors[0]].nil? || @@all_interactions[interactors[0]].length > 1 
                        # if it has one interaction (we know from above it is not in @@gene_array), we want to repeat the process
                        to_be_removed = interactors[0] # setting to_be_removed to this id so that it also gets removed from @@all_interactions
                    end
                else # if interactors.length != 1                    
                    break # exit the while loop if more than one interaction were removed
                end
            end
        end
    end
    
    #
    # Finds interactions from the IntAct database 
    # where both members are from Arabidopsis thaliana,
    # one of them is from a list of genes,
    # and the miscore is greater or equal than a threshold.
    # It adds them to @@all_interactions
    #
    # @param [Float] cutoff The threshold for the miscore, default 0.45
    # @param [Array<Symbol>] gene_array The list of genes, default @@gene_array
    #
    def self.find_interactions_intact(cutoff = 0.45, gene_array = @@gene_array)
        puts "Finding interactions..."
        gene_array.each do |gene_id|
            next unless gene_id =~ /[Aa][Tt]\w[Gg]\d\d\d\d\d/ # we only want AGI locus codes
            url = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene_id}?format=tab25"
            response = InteractionNetwork.fetch(url)
            if response && !response.body.empty? # ruby uses short-circuit evaluation, if response is false, the second half doesn't get evaluated
                response.body.each_line do |tab25|
                    fields = tab25.split("\t")
                    # fields 4 and 5 contain the interacting genes, fields 9 and 10 contain the species, fields 14 contains the mi-score
                    # I'm not filtering by interaction type, but if I had to, I would filter by the field 11 (for example: psi-mi:"MI:0915"(physical association))
                    
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
                    unless gene2 == gene_id || gene1 == gene_id # shouldn't happen but just in case none of the genes equal the original gene_id
                        puts "WARNING: unexpected, none of the gene ids of the interaction (#{gene1} #{gene2}) are the original gene #{gene_id}" # warning
                        next # skip
                    end
                    InteractionNetwork.add_interaction_to_hash(gene_id, new_gene) # adding the interaction
                end
            end
        end
    end
        
    #
    # Creates InteractionNetwork objects using the interactions in @@all_interactions.
    # At least two genes of each network are present in @@gene_array.
    #
    def self.create_networks_rgl
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
        # Before starting, I'm removing the unnecessary interactions (interactions with genes not in @@gene_array that don't lead anywhere)
        InteractionNetwork.remove_unimportant_branches
        puts "Creating the networks..."
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
            # if that connected component has two or more genes from @@gene_array, build an InteractionNetwork
            if num_genes_in_array >= 2
                parameters = {net_interactions: InteractionNetwork.get_interactions_from_all_interactions(subgraph_nodes)}
                if parameters[:net_interactions].nil?
                    puts "WARNING: for genes #{subgraph_nodes} something went wrong when creating the InteractionNetwork, there were no interactions found even though there should have been."
                    next
                else
                    InteractionNetwork.new(parameters) # creating the new InteractionNetwork.
                end
            end
        end
    end
    
    #
    # Get the genes contained in an InteractionNetwork object
    #
    # @return [Array<Symbol>] The array of genes
    #
    def genes
        return @network_graph.vertices # returns an array of the genes
    end
    
    #
    # Get the genes contained in an InteractionNetwork object,
    # distinguishing between genes that are present in @@gene_array and genes that aren't.
    #
    # @return [Hash] Hash with the genes, :gene_list => [Array of genes that are in @@gene_array], :intact => [Array of genes that are not in @@gene_array]
    #
    def genes_with_origin
        gene_hash = {gene_list: [], intact: []}
        gene_hash[:gene_list] = @network_graph.vertices.select {|gene| @@gene_array.include? gene} # genes from the network that are in @@gene_array
        gene_hash[:intact] = @network_graph.vertices.select {|gene| !gene_hash[:gene_list].include? gene} # the rest of the genes from the network
        return gene_hash
    end
    
    #
    # Get the interactions contained in an InteractionNetwork object as an array of arrays
    # [[source1, target1], [source2, target2] ...]
    #
    # @return [Array<Array<Symbol>>] The array of interactions
    #
    def interactions
        return @network_graph.edges.map &:to_a
    end
    
    #
    # Get the interactions contained in an InteractionNetwork object as a hash
    #
    # @return [Hash] The hash of interactions in the same format as @@all_interactions
    #
    def interactions_as_hash
        interaction_array = self.interactions
        interaction_hash = {}
        interaction_array.each do |interaction|
            InteractionNetwork.add_interaction_to_hash(*interaction, hash=interaction_hash) # adding the interaction to the hash
        end
        return interaction_hash # returns a hash of interactions, with every interaction twice (bidirectional)
    end
    
    #
    # Get the interactions contained in an InteractionNetwork object as an array of edges
    #
    # @return [Array<RGL::Edge::UnDirectedEdge>] The array of interactions
    #
    def interactions_as_edges
        return @network_graph.edges # returns each interaction as RGL::Edge::UnDirectedEdge object
    end

    #
    # Get the interactions contained in an InteractionNetwork object as a string
    #
    # @param [String] int The string that denotes the interaction, default "<-->"
    # @param [String] sep The separator that goes at the end of each interaction, default "\n"
    #
    # @return [String] The string with all the interactions of the network
    #
    def interactions_as_string(int = "<-->", sep = "\n")
        interaction_array = self.interactions
        result_string = ""
        interaction_array.each do |interaction|
            source, target = *interaction
            result_string << "#{source} #{int} #{target}#{sep}"
        end
        return result_string
    end
    
    #
    # Writes a report to a file detailing the genes of a network, the interactions,
    # and the KEGG and GO annotations for those genes.
    #
    # @param [String] filename The name of the file, default "Report.txt"
    #
    def self.write_report(filename = "Report.txt")
        puts "Writing the report..."
        
        gene_counter = 0
        total_genes_num = @@gene_array.length
        f = File.new(filename, "w") # opening the file
        
        @@all_networks.each_with_index do |network, index|
            f.write "--------------------------------------------\n"
            f.write "Network #{index + 1}\n"
            network_genes = network.genes_with_origin
            gene_counter += network_genes[:gene_list].length # incrementing the counter
            f.write "Genes from the gene list: #{network_genes[:gene_list].join(" ")}\n"
            f.write "Interactions: \n"
            f.write network.interactions_as_string
            if network.annotations_hash[:KEGG]
                f.write "KEGG annotations for all the genes in the network: \n"
                network.annotations_hash[:KEGG].each do |kegg_id, kegg_pathway|
                    f.write "ID: #{kegg_id}, pathway name: #{kegg_pathway}\n"
                end
            else
                f.write "No KEGG pathways found for the genes in the network. \n"
            end
            if network.annotations_hash[:GO]
                f.write "GO annotations for all the genes in the network: \n"
                network.annotations_hash[:GO].each do |go_id, go_process|
                    f.write "ID: #{go_id}, process: #{go_process}\n"
                end
            else
                f.write "No GO annotations found for the genes in the network. \n"
            end
            f.write "--------------------------------------------"
        end
        f.write "\nFrom the #{total_genes_num} genes of the gene list, #{gene_counter} are present in interaction networks."
        
        f.close() # closing the file        
    end
    
end