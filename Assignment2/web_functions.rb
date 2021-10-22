require 'rest-client'

# Function fetch to access an URL via code, donated by Mark Wilkinson.
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

response = fetch(url = "http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/At4g18960?format=tab25").body

response.each_line.with_index do |line, index|
    puts line.split("\t") if index == 4
end


# IntAct URL format
# http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/At4g18960?format=tab25

# Species:
# 9
# taxid:3702(arath)|taxid:3702("Arabidopsis thaliana (Mouse-ear cress)")
# 10
# taxid:3702(arath)|taxid:3702("Arabidopsis thaliana (Mouse-ear cress)")

# Score:
# https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7708836/
# "authors recommend a MIscore range of 0.45–1 to identify medium confidence interactions and 0.6–1 for high confidence sets"
# 14
# intact-miscore:0.37

# I'm going to use a score > 0.45 and consider interactions A->X and A->intermediate->X, where A and X are on the list of genes

'''
0
uniprotkb:P17839
1
uniprotkb:Q9C633
2
intact:EBI-592365|uniprotkb:O82732
3
intact:EBI-622475|uniprotkb:C0SUZ7
4
psi-mi:ag_arath(display_long)|uniprotkb:F13C5.130(orf name)|uniprotkb:AG(gene name)|psi-mi:AG(display_short)|uniprotkb:At4g18960(locus name)
5
psi-mi:agl97_arath(display_long)|uniprotkb:At1g46408(locus name)|uniprotkb:AGL97(gene name)|psi-mi:AGL97(display_short)|uniprotkb:F2G19.10(orf name)
6
psi-mi:"MI:0018"(two hybrid)
7
de et al. (2005)
8
pubmed:15805477
9
taxid:3702(arath)|taxid:3702("Arabidopsis thaliana (Mouse-ear cress)")
10
taxid:3702(arath)|taxid:3702("Arabidopsis thaliana (Mouse-ear cress)")
11
psi-mi:"MI:0915"(physical association)
12
psi-mi:"MI:0469"(IntAct)
13
intact:EBI-623194
14
intact-miscore:0.37
'''