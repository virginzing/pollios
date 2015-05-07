require 'rest_client'

module Authenticate

	class Logger
		def self.log(name, response)
			puts "(#{Time.now.strftime("%d %B %Y, %H:%M:%S")}) #{name} => #{response}"
		end
	end

	class Sentai < Logger

		def self.set_up_host_url
			Rails.env.production? ? "http://codeapp-user.herokuapp.com" : "http://codeapp-user-dev.herokuapp.com"
		end

		def self.signin(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/signin.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.signup(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/signup.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.multi_signup(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/multi_signup.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.update_profile(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/update_profile.json", params)
			response = JSON.parse(res_form_sentai.body)
			log("UpdateProfile", response)
			if response["response_status"] == "OK" && response.present?
      	member = Member.update_profile(response)
      else
      	member = nil
	    end
	    return response, member
		end

		def self.forgot_password(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/forgot_password.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.reset_password(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/reset_password.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.change_password(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/change_password.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

		def self.verify_email(params)
			res_form_sentai = RestClient.post("#{set_up_host_url}/codeapp/verify_email.json", params)
			response = JSON.parse(res_form_sentai.body)
		end

	end
end