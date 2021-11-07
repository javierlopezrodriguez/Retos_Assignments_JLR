require_relative "./assignment3_functions.rb"

gene_array = read_gene_list(path = "../Assignment2/ArabidopsisSubNetwork_GeneList.txt")
embl_hash = get_embl(gene_array[0..10].append(:AT2G46340.downcase))
new_embl_hash = find_seq_in_exons(embl_hash)
write_gff3_local(new_embl_hash, filename = "CTTCTT_GFF3_gene.gff")
write_gff3_global(new_embl_hash, filename = "CTTCTT_GFF3_chromosome.gff")
write_report(gene_array, new_embl_hash, filename = "CTTCTT_report.txt")