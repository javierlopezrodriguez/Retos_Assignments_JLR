require_relative 'assignment3.rb'

gene_array = [:AT4g27030]

embl = get_embl(gene_array)

bio_embl = embl[gene_array[0]]

puts bio_embl

puts bio_embl.seq

bio_embl.features.each do |feature|
    puts feature.seq
end