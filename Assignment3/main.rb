require_relative "./assignment3_functions.rb"

# ruby main.rb ../Assignment2/ArabidopsisSubNetwork_GeneList.txt

if ARGV.length < 1
    puts "You need to include the input gene list as an argument"
    abort
end

gene_array = read_gene_list(path = ARGV[0])
embl_hash = get_embl(gene_array)
new_embl_hash = find_seq_in_exons(embl_hash)
write_gff3_local(new_embl_hash, filename = "CTTCTT_GFF3_gene.gff")
write_gff3_global(new_embl_hash, filename = "CTTCTT_GFF3_chromosome.gff")
write_report(gene_array, new_embl_hash, filename = "CTTCTT_report.txt")