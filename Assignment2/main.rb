require_relative './InteractionNetwork.rb'

if ARGV.length < 1
    puts "You need to include the input gene list as an argument"
else
    puts "No output name has been given, the default Report.txt will be generated" if ARGV.length == 1
    # Setting the class variables to the default state
    InteractionNetwork.start
    InteractionNetwork.read_gene_list(ARGV[0])
    InteractionNetwork.find_interactions_intact(cutoff = 0.45)
    InteractionNetwork.create_networks_rgl
    InteractionNetwork.write_report(ARGV[1]) if ARGV.length > 1
    InteractionNetwork.write_report unless ARGV.length > 1
end

