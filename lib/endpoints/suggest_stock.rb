require 'xmlsimple'

module StockChecker
	class Application < Sinatra::Base


		post '/suggest/?' do
			messages = []
			params = JSON.parse(request.env["rack.input"].read, :symbolize_names => true)

			uri = URI('https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&type=&company=&dateb=&owner=only&start=0&count=100&output=atom')
      		resp = Net::HTTP.get(uri)

      		xml_hash = XmlSimple.xml_in(resp, {'KeyAttr' => 'name'})


      		xml_hash['entry'][0..6].each do |entry|
      			next unless entry['title'][0] =~ /Reporting/

      			link = entry['link'][0]['href']
      			#puts link

      			uri = URI(link)
      			begin
					new_resp_html = Net::HTTP.get(uri)
				rescue
					next
				end
				#now in the doc we want
				xml_link = new_resp_html.split(/<tr class="blueRow">/,2)[1].split(/<\/tr>/,2)[0].split(/href="/)[1].split(/">/)[0]
				#now in the doc we want
				#puts xml_link
				uri = URI('https://www.sec.gov/' + xml_link)
      			begin
					new_resp_xml = Net::HTTP.get(uri)
					#puts new_resp_xml
				rescue
					next
				end
				#now in the doc we want
				
				final_xml_hash = XmlSimple.xml_in(new_resp_xml, {'KeyAttr' => 'name'})
				#puts final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionAcquiredDisposedCode'][0]['value'][0] 
				stocksymbol = final_xml_hash['issuer'][0]['issuerTradingSymbol']
				#AorD = final_xml_hash['transactionAcquiredDisposedCode'][0]['value']
				transaction = final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionAcquiredDisposedCode'][0]['value'][0] == 'A' ? 'acquired' : 'sold'
      			# lastbit = link.split('/')[-1]
      			# new_link = link.sub(lastbit, 'form4.xml')
      			amount = final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionShares'][0]['value'][0]
      			# puts "\n\n\n#{new_link}"
      			#puts final_xml_hash
      			messages << "A form4 filer just #{transaction} $#{amount} worth of #{stocksymbol}"
  			
      		end

      		message = {
              :color => "green",
              :message => messages.join("\n"),
              :notify => false,
              :message_format => 'text'
            } 
      		
      		message.to_json
		end
	end
end
