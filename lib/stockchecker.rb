require 'sinatra'
require 'json'
require 'net/http'

module StockChecker
	class Application < Sinatra::Base


    get '/stock/?' do
      results = {}
      message = {}
      uri = URI('http://finance.yahoo.com/webservice/v1/symbols/'+ params['symbol']+'/quote?format=json')
      resp = Net::HTTP.get(uri)
      resp_hash = JSON.parse(resp, {:symbolize_names => true})

      if resp_hash[:list][:meta][:count] > 0
        resp_hash[:list][:resources].each do |resource|

          if resource[:resource][:classname] == "Quote"
            message = {
              :color => "green",
              :message => "#{resource[:resource][:fields][:name].to_s} is #{resource[:resource][:fields][:price].to_s}",
              :notify => false,
              :message_format => 'text'
            } 
  
            results = message
            break
          end
        end
      end

      results.to_json
    end
  end
end

