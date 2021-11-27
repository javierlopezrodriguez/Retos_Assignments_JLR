Assignment 4. Command to run:

ruby main.rb ./blast_databases/arabidopsis_thaliana.fa ./blast_databases/schizosaccharomyces_pombe.fa


About the fasta files:

In this case, the fasta files provided for Arabidopsis and S. pombe don't have the problem we mentioned in class about the non-unique identifiers.


About the parameters:

From https://doi.org/10.1093/bioinformatics/btm585

They recommend an E-value threshold of 1*10^-6 and that there is a query coverage of at least 50%.

Also, the best detection of orthologs as best reciprocal hits was obtained with soft filtering and a Smith-Waterman final alignment (-F “m S” -s T), giving both the highest number of orthologs and the minimal error rates. However, using a Smith-Waterman final alignment is computationally expensive, and almost the same results were achieved just by using soft filtering (-F “m S”), which is what I'll use.


Next steps in the search of orthologs:

COMPLETE THIS!!






