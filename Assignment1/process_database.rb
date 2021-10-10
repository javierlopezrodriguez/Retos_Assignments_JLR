require './HybridCrossDatabaseObject.rb'
require './StockDatabaseObject.rb'
require './GeneDatabaseObject.rb'

# ruby process_database.rb gene_information.tsv seed_stock_data.tsv cross_data.tsv output_test_1.tsv


if ARGV.length < 4
    puts "You need to include, in this order, the names of: gene_file, seed_stock_file, cross_file, and output_file"
else # everything ok

    # Creating each database object, and loading the database from each file
    gene_db = GeneDatabase.new
    gene_db.load_from_file(ARGV[0])
    stock_db = StockDatabase.new
    stock_db.load_from_file(ARGV[1])
    cross_db = HybridCrossDatabase.new
    cross_db.load_from_file(ARGV[2])
    
    # Adding each Gene object to the corresponding SeedStock object (this is not necessary)
    stock_db.all_entries.each {|seed_stock| seed_stock.add_gene_object(gene_db)}
    
    # Simulating planting 7 grams of seeds of each record
    stock_db.all_entries.each {|seed_stock| seed_stock.decrease_quantity(grams = 7)}
    
    # Writing the new state of the stock database to a new file
    stock_db.write_database(ARGV[3])
    
    # Processing the hybrid cross information
    cross_db.all_entries.each {|cross| cross.chi_square_test} # chi square test for each hybrid cross
    cross_db.annotate_linked_genes_and_report(stock_db, gene_db) # annotating the linked genes and printing a report
end