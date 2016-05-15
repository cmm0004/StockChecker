module StockChecker
	class Application < Sinatra::Base
	
		
		post '/jobluv/?' do
			params = JSON.parse(request.env["rack.input"].read, :symbolize_names => true)
			incoming_message = params[:item][:message][:message].split(' ')
			mentioned_user = params[:item][:message][:mentions][0][:mention_name]
			action = incoming_message[-1]
			#possible usages 
			#/Jobluv <user> <++>
			#/Jobluv <user> <-->

			if action == '++'
				return {
						color: "green",
						message: "#{mentioned_user} #{get_plus_jobluv_links().sample}",
						notify: false,
						message_format: "text"
					}.to_json
			elsif action == '--'
				return {
						color: "red",
						message: "#{mentioned_user} #{get_minus_jobluv_links().sample}",
						notify: false,
						message_format: "text"
					}.to_json
			end

			status 403
		end

		

		def get_plus_jobluv_links
				links = [
					#yousmart
					'https://i.imgur.com/OfPEnFZ.gif',
					#champaign on booty
					'https://m.popkey.co/a39a1a/7zxGZ.gif',
					#i appreciate you
					'https://m.popkey.co/ea155c/G0AgD.gif'
				]
			end

			def get_minus_jobluv_links
				links = [
					#some people cant handle success
					'https://m.popkey.co/3060d3/DYgpr.gif',
					#congrats you PLAYED YOURSELF.
					'http://i.makeagif.com/media/10-12-2015/mQJF9e.gif'
				]
			end
	end
end