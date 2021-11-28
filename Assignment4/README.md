Assignment 4. Command to run:

ruby main.rb ./blast_databases/schizosaccharomyces_pombe.fa ./blast_databases/arabidopsis_thaliana.fa


About the fasta files:

In this case, the fasta files provided for Arabidopsis and S. pombe don't have the problem we mentioned in class about the non-unique identifiers.


About the parameters:

From https://doi.org/10.1093/bioinformatics/btm585

They recommend an E-value threshold of 1*10^-6 and that there is a query coverage of at least 50%.

Also, the best detection of orthologs as best reciprocal hits was obtained with soft filtering and a Smith-Waterman final alignment (-F “m S” -s T), giving both the highest number of orthologs and the minimal error rates. However, using a Smith-Waterman final alignment is computationally expensive, and almost the same results were achieved just by using soft filtering (-F “m S”), which is what I'll use.


Next steps in the search of orthologs:

From https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3193375/

A reasonable next step would be to include a third species, and perform a COG search (cluster of orthologous genes), a clustering method based on best reciprocal hit. We could identify the best reciprocal hits between the three species, and find the clusters that contain a best reciprocal hit from the three species. Because we have included one additional species, it is more probable that the orthologous genes we find here are really orthologous.

Furthermore, we could use tree-based approaches, building phylogenetic gene trees between three or more species, and looking for orthologous genes between our species of interest.






