require_relative './assignment4_functions.rb'

# ruby main.rb ./blast_databases/arabidopsis_thaliana.fa ./blast_databases/schizosaccharomyces_pombe.fa

abort("You need to include both databases, example of the command: ruby main.rb ./blast_databases/arabidopsis_thaliana.fa ./blast_databases/schizosaccharomyces_pombe.fa") if ARGV.length < 2

#Getting both arguments
db1 = ARGV[0]
db2 = ARGV[1]
# Creating the blast databases and returning their names and type
db1_hash = make_blast_db(db1)
db2_hash = make_blast_db(db2)
# Getting the best reciprocal hits
    # From https://doi.org/10.1093/bioinformatics/btm585
    # They recommend an E-value threshold of 1*10^-6
    # and that there is a query coverage of at least 50%.
    # Also, the best detection of orthologs as best reciprocal hits was obtained with soft filtering and a Smith-Waterman final alignment
    # (-F “m S” -s T), giving both the highest number of orthologs and the minimal error rates. However, using a Smith-Waterman final alignment
    # is computationally expensive, and almost the same results were achieved just by using soft filtering (-F “m S”), which is what I'll use.
brh = get_best_reciprocal_hits(db1_hash, db2_hash, evalue = "1e-6", filtering = "'m S'", coverage = 0.5)
# Writing the report
write_report(brh)

