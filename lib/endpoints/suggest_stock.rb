require 'xmlsimple'

module StockChecker
	class Application < Sinatra::Base


		post '/suggest/?' do
			messages = []
			
			uri = URI('https://www.sec.gov/cgi-bin/browse-edgar?action=getcurrent&type=&company=&dateb=&owner=only&start=0&count=100&output=atom')
      		resp = Net::HTTP.get(uri)

      		xml_hash = XmlSimple.xml_in(resp, {'KeyAttr' => 'name'})


      		xml_hash['entry'][0..9].each do |entry|
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
				
				ownerstring = determine_owner(final_xml_hash['reportingOwner'][0]['reportingOwnerRelationship'][0])
				
				stocksymbol = final_xml_hash['issuer'][0]['issuerTradingSymbol'][0]
			
				
				shares = final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionShares'][0]['value'][0]

				price_per_share = final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionPricePerShare'][0]['value'][0]
				
				type_of_purchase = determine_transaction_type(final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionAcquiredDisposedCode'][0]['value'][0])

      			amount = final_xml_hash['nonDerivativeTable'][0]['nonDerivativeTransaction'][0]['transactionAmounts'][0]['transactionShares'][0]['value'][0]
      		
      			messages << "A #{ownerstring} just #{type_of_purchase} #{shares} shares of #{stocksymbol} at #{price_per_share} per share."
  			
      		end

      		message = {
              :color => "green",
              :message => messages.join("\n"),
              :notify => false,
              :message_format => 'text'
            } 
      		
      		message.to_json
		end

		def determine_owner(relationship_hash)
			isDirector = nil
			isOfficer = nil
			isTenPercentOwner = nil
			isOther = nil
			title = nil
			if !relationship_hash['isDirector'].nil?
				case relationship_hash['isDirector'][0]
					when (String and '1')
						isDirector = 'Director,'
					when (Integer and 1)
						isDirector = 'Director,'
					
					when (String and ('true' or 'True' or 'TRUE'))
						isDirector = 'Director,'
					end
			end

			if !relationship_hash['isOfficer'].nil?
				case relationship_hash['isOfficer'][0]
					when (String and '1')
						isDirector = 'Officer,'
					when (Integer and 1)
						isDirector = 'Officer,'
					
					when (String and ('true' or 'True' or 'TRUE'))
						isDirector = 'Officer,'
					end
			end
			if !relationship_hash['isTenPercentOwner'].nil?
				case relationship_hash['isTenPercentOwner'][0]
					when (String and '1')
						isDirector = 'TenPercentOwner,'
					when (Integer and 1)
						isDirector = 'TenPercentOwner,'
					
					when (String and ('true' or 'True' or 'TRUE'))
						isDirector = 'TenPercentOwner,'
					end
			end

			if !relationship_hash['isOther'].nil?
				case relationship_hash['isOther'][0]
					when (String and '1')
						isDirector = 'Other,'
					when (Integer and 1)
						isDirector = 'Other,'
					
					when (String and ('true' or 'True' or 'TRUE'))
						isDirector = 'Other,'
					end
			end

			if !relationship_hash['title'].nil?
				title = !relationship_hash['officerTitle'][0].nil? ? relationship_hash['officerTitle'][0] : ''
			end


			return "#{isDirector} #{isOfficer} #{isTenPercentOwner} #{isOther} #{title}"

		end

		def determine_transaction_type(transaction_type)
			case transaction_type
				when 'A'
					'aquired'
				when 'D'
					'disposed of'		
				else
					'moved'
			end
		end


	end
end
