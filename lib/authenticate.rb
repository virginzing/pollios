require 'rest_client'

module Authenticate

	class Logger
		def self.log(name, response)
			puts "(#{Time.now.strftime("%d %B %Y, %H:%M:%S")}) #{name} => #{response}"
		end
	end

	class Sentai < Logger

		def self.signin(params)
			res_form_sentai = RestClient.post("http://codeapp-user.herokuapp.com/codeapp/signin.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.signup(params)
			res_form_sentai = RestClient.post("http://codeapp-user.herokuapp.com/codeapp/signup.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.update_profile(params)
			res_form_sentai = RestClient.post("http://codeapp-user.herokuapp.com/codeapp/update_profile.json", params)
			response = JSON.parse(res_form_sentai.body)
			log("UpdateProfile", response)
			if response["response_status"] == "OK" && response.present?
      	member = Member.update_profile(response)
      else
      	member = nil
	    end
	    return response, member
		end

	end
end