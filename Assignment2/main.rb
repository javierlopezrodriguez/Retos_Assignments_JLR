require_relative './InteractionNetwork.rb'

if ARGV.length < 1
    puts "You need to include the input gene list as an argument"
else
    puts "No output name has been given, the default Report.txt will be generated" if ARGV.length == 1
    
    puts "Only direct interactions (A <--> B) and indirect interactions with one degree of separation (A <--> X, X <--> B)"

    # First, looking only for the interactions with a quality score >= 0.6 (high quality)
    puts "Filtering, only showing high-quality interactions"
    InteractionNetwork.start # setting the class variables to the default state
    InteractionNetwork.read_gene_list(ARGV[0])
    InteractionNetwork.find_interactions_intact(cutoff = 0.6)
    InteractionNetwork.create_networks_rgl
    InteractionNetwork.write_report("High-quality-#{ARGV[1]}") if ARGV.length > 1
    InteractionNetwork.write_report("High-quality-report.txt") unless ARGV.length > 1

    # Second, looking only for the interactions with a quality score >= 0.45 (medium and high quality)
    puts "Filtering, only showing medium- and high-quality interactions"
    InteractionNetwork.start # setting the class variables to the default state
    InteractionNetwork.read_gene_list(ARGV[0])
    InteractionNetwork.find_interactions_intact(cutoff = 0.45)
    InteractionNetwork.create_networks_rgl
    InteractionNetwork.write_report("Medium-quality-#{ARGV[1]}") if ARGV.length > 1
    InteractionNetwork.write_report("Medium-quality-report.txt") unless ARGV.length > 1

    # Then, for comparison, looking for the interactions without filtering for quality
    puts "Not filtering for quality"
    InteractionNetwork.start
    InteractionNetwork.read_gene_list(ARGV[0])
    InteractionNetwork.find_interactions_intact(cutoff = 0) # no cutoff, no filtering for quality
    InteractionNetwork.create_networks_rgl
    InteractionNetwork.write_report("Unfiltered-#{ARGV[1]}") if ARGV.length > 1
    InteractionNetwork.write_report("Unfiltered-report.txt") unless ARGV.length > 1

end

