require '../Assignment1/GeneDatabaseObject.rb'
require 'rest-client'  

# ruby embl.rb gene_information.tsv

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

# for each gene in gene_db:
gene_db.all_entries.each do |gene_object|
    gene_id = gene_object.id
    embl_url = "https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=" + gene_id
    response = fetch(embl_url)
    
    if response
        body = response.body 
    end
end
