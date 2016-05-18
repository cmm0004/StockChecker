require './lib/models/jobluv'

module StockChecker
	class Application < Sinatra::Base
		include Models

		post '/jobluv/?' do
			params = JSON.parse(request.env["rack.input"].read, :symbolize_names => true)
			incoming_message = params[:item][:message][:message].split(' ')
			mentioned_user = params[:item][:message][:mentions][0][:mention_name]
			action = incoming_message[-1]
			#possible usages 
			#/Jobluv <user> <++>
			#/Jobluv <user> <-->
			return {    color: "red",
						message: "You kno I 'preciate tha luv, but ya gotta tell me who",
						notify: false,
						message_format: "text"
					}.to_json unless !mentioned_user.blank?

			user = StockChecker::Models::Jobluv.find_by(:hipchat_username => mentioned_user)
			 

			if !user.nil? 
				if action == '++'
					begin
						user.update!(:jobluv_amount => (user.jobluv_amount += 1) )
					rescue => e
						return {
							color: "red",
							message: "Exception raised: #{e} for request: #{params}",
							notify: false,
							message_format: "text"
						}.to_json
					end

					return {
						color: "green",
						message: "@#{mentioned_user} #{get_plus_jobluv_links().sample}",
						notify: false,
						message_format: "text"
					}.to_json

				elsif action == '--'
					begin
						user.update!(:jobluv_amount => (user.jobluv_amount -= 1) )
					rescue => e
						return {
							color: "red",
							message: "Exception raised: #{e} for request: #{params}",
							notify: false,
							message_format: "text"
						}.to_json
					end

					return {
						color: "red",
						message: "#@{mentioned_user} #{get_minus_jobluv_links().sample}",
						notify: false,
						message_format: "text"
					}.to_json
				elsif action == '?'
					keys = '(key)' * user.jobluv_amount
					return {
							color: "green",
							message: "#@{user.hipchat_username} is major #{keys}",
							notify: false,
							message_format: "text"
						}.to_json
				end
			else 
				begin
					StockChecker::Models::Jobluv.create!(
						:hipchat_username => mentioned_user,
						:jobluv_amount => 0,
						:is_the_job_don => false)
				rescue => e
					return {
						color: "red",
						message: "Exception raised: #{e} for request: #{params}",
						notify: false,
						message_format: "text"
					}.to_json
				end

				return {
						color: "green",
						message: "You are now on the road to success @#{mentioned_user} , ride wit me.",
						notify: false,
						message_format: "text"
					}.to_json
			end
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