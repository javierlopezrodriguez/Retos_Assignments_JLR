require_relative '../Assignment1/GeneDatabaseObject.rb' # require_relative so that the path is relative to this file
require_relative './AnnotatedGeneObject.rb'
require 'rest-client'  

# ruby embl.rb ../Assignment1/gene_information.tsv

# Create a function called "fetch" that we can re-use everywhere in our code

def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
    response = RestClient::Request.execute({
        method: :get,
        url: url.to_s,
        user: user,
        password: pass,
        headers: headers})
    return response
    
    rescue RestClient::ExceptionWithResponse => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    rescue RestClient::Exception => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    rescue Exception => e # generic
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end 

# creating a gene database and loading genes from file:
gene_db = GeneDatabase.new
gene_db.load_from_file(ARGV[0])

# hash to store all the embl entries:
embl_entries = {} # gene_id: body
embl_uniprot_id = {} # gene_id: uniprot_id

# for each gene in gene_db:
gene_db.all_entries.each do |gene_object|
    gene_id = gene_object.id
    embl_url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=" + gene_id
    response = fetch(embl_url)
    
    if response
        body = response.body 
        embl_entries[gene_id] = body
        # find uniprot xref id:
        # db_xref="Uniprot/SWISSPROT:XXXXXXXX"
        uniprot_xref = Regexp.new('db_xref="Uniprot/SWISSPROT:(\w+)"')
        uniprot_xref_match = uniprot_xref.match(body)
        if uniprot_xref_match
            embl_uniprot_id[gene_id] = uniprot_xref_match[1]
        end
    end
end

annotated_gene_hash = {} #gene_id: AnnotatedGene object

# getting the dna seq and the protein seq for each gene object, and creating an annotated gene object with it
embl_uniprot_id.each do |gene_id, uniprot_id|
    dna_url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&style=raw&id=" + gene_id
    prot_url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=uniprotkb&format=fasta&style=raw&id=" + uniprot_id
    dna_response = fetch(dna_url)
    prot_response = fetch(prot_url)

    gene_obj = gene_db.get_object_by_id(gene_id) # get the normal gene object from the database
    params = {gene_id: gene_obj.id, 
              gene_name: gene_obj.name, 
              mutant_phenotype: gene_obj.mutant_phenotype, 
              linked: gene_obj.linked, 
              dna_seq: dna_response, 
              prot_seq: prot_response, 
              prot_id: uniprot_id}

    annotated_gene_obj = AnnotatedGene.new(params)

    if dna_response
        annotated_gene_obj.dna_seq = dna_response.body
    end

    if prot_response
        annotated_gene_obj.prot_seq = prot_response.body
    end

    annotated_gene_hash[gene_id] = annotated_gene_obj
end

# Report:
annotated_gene_hash.values.each do |annotated_gene_obj|
    puts "AGI_Locus: " + annotated_gene_obj.id.to_s
    puts "Gene_Name: " + annotated_gene_obj.name.to_s
    puts "Protein_ID: " + annotated_gene_obj.prot_id.to_s
    puts "\nDNA sequence: \n" + annotated_gene_obj.dna_seq.to_s
    puts "\nProt sequence: \n" + annotated_gene_obj.prot_seq.to_s
end