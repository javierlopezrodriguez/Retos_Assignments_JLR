This code uses the gem rgl, version 0.5.7, to work with graphs in ruby
(https://github.com/monora/rgl)
I have installed it using:
sudo gem install rgl

Command to run the code:

ruby main.rb ArabidopsisSubNetwork_GeneList.txt Report1.txt

Command to run the tests:

ruby AnnotationTest.rb

ruby InteractionNetworkTest.rb

-----------------------------------

I've obtained three reports, finding interactions in the IntAct database and using different filters for the quality of the interactions.

Unfiltered-Report1.txt contains the unfiltered interactions.
I've obtained 4 networks, which include 44 out of the 168 genes from ArabidopsisSubNetwork_GeneList.txt

Medium-quality-Report1.txt contains the medium and high quality interactions (with a miscore >= 0.45).
I've obtained 2 networks, which include 11 out of the 168 genes.

High-quality-Report1.txt contains the high quality interactions (with a miscore >= 0.6).
I've only obtained 1 network, which includes only a direct interaction between 2 of the 168 genes.

I have only considered direct interactions (A <--> B, both of them in the gene list) and indirect interactions with one degree of separation (A <--> X, X <--> B, where A and B are in the gene list, and X is not).

Using filtering restricts the amount of interactions that are found. However, even when not filtering, only 44 out of the 168 genes are shown to have protein-protein interactions with other members of the gene list. I think that some members of the gene list form protein-protein interaction networks, but not all of them.
