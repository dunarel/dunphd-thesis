
require 'rubygems'
require 'rest_client'

RestClient.post('http://www.ncbi.nlm.nih.gov/Taxonomy/TaxIdentifier/tax_identifier.cgi', :tax => "2", :button =>"Show on screen") {
|response, request, result| 
 puts response
}



