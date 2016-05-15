require './lib/helpers/djkhaled_links'

module StockChecker
	class Application < Sinatra::Base
		include Helpers::DjKaledLinks
		
		post '/jobluv/?' do
			params = JSON.parse(request.env["rack.input"].read, :symbolize_names => true)
			incoming_message = params[:item][:message][:message].split(' ')
			mentioned_user = params[:item][:message][:mentions][0][:mention_name]
			action = determine_action(incoming_message[-1])
			#possible usages 
			#/Jobluv <user> <++>
			#/Jobluv <user> <-->

			if action == '++'
				return {
						color: "green",
						message: DjKaledLinks.get_plus_jobluv_links.sample,
						notify: false,
						message_format: "text"
					}.to_json
			elsif action == '--'
				return {
						color: "red",
						message: DjKaledLinks.get_minus_jobluv_links.sample,
						notify: false,
						message_format: "text"
					}.to_json
			end

			status 403
		end

		

		post '/portfolio/?' do
			params = JSON.parse(request.env["rack.input"].read, :symbolize_names => true)
			incoming_message = params[:item][:message][:message].split(' ')
			mentioned_user = params[:item][:message][:mentions][0][:mention_name]
			stock_to_add = incoming_message[-1]

			if incoming_message[1] =~ /addstock/
				begin
					StockChecker::Models::Portfolio.create!(
						hipchat_username: mentioned_user,
						stock_name: stock_to_add)
				rescue exception => ex
					return {
						color: "red",
						message: ex,
						notify: false,
						message_format: "text"
					}.to_json
				end

				user_portfolio = StockChecker::Models::Portfolio.where(hipchat_username: mentioned_user).order(created_at: :asc)
				stocks = []
				user_portfolio.each do |stock|
					stocks << stock.stock_name
				end

				return {
						color: "green",
						message: "Added #{stock_to_add}, #{mentioned_user} 's Portfolio:\n #{stocks.join(",")}",
						notify: false,
						message_format: "text"
					}.to_json 
			end
		end
	end
end