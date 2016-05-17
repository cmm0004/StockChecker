require 'sinatra'
require 'json'
require 'net/http'
require './config/environments'
require './lib/endpoints/suggest_stock'
require './lib/endpoints/jobluv'

module StockChecker
	class Application < Sinatra::Base


    post '/stock/?' do
      results = {}
      message = {}
      params = JSON.parse(request.env["rack.input"].read, :symbolize_names => true)
      puts params.inspect
      incoming_message = params[:item][:message][:message].split(' ')
      


      uri = URI('http://finance.yahoo.com/webservice/v1/symbols/'+ incoming_message[-1] +'/quote?format=json')
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

