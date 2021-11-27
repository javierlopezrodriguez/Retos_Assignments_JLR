require 'bio'
require_relative './assignment4_functions.rb'

# ruby main.rb ./blast_databases/arabidopsis_thaliana.fa ./blast_databases/schizosaccharomyces_pombe.fa

abort("You need to include both databases, example of the command: ruby main.rb ./blast_databases/arabidopsis_thaliana.fa ./blast_databases/schizosaccharomyces_pombe.fa") if ARGV.length < 2

#Getting both arguments
db1 = ARGV[0]
db2 = ARGV[1]
# Creating the blast databases
db1_hash = make_blast_db(db1)
db2_hash = make_blast_db(db2)

