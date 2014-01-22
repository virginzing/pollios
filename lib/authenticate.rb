require 'rest_client'

module Authenticate

	class Logger
		def self.log(name, response)
			puts "(#{Time.now.strftime("%d %B %Y, %H:%M:%S")}) #{name} => #{response}"
		end
	end

	class Sentai < Logger

		def self.signin(url, params)
			res_form_sentai = RestClient.post(url, params)
			@response = JSON.parse(res_form_sentai.body)
			log("Signin", @response)

			if @response["response_status"] == "OK" && @response.present?
				@outh_sentai = Member.identify_access(@response)
				log("signin detail", @outh_sentai)
			else
				@outh_sentai = nil
			end
			return @outh_sentai 
		end

		def self.signup(url, params, app_name)
			res_form_sentai = RestClient.post(url, params.merge!({"app_name" => app_name}))
			@response = JSON.parse(res_form_sentai.body)
			log("Signup", @response)

			if @response["response_status"] == "OK" && @response.present?
	      @outh_sentai = Member.identify_access(@response)
	      log("signup detail", @outh_sentai)
	    end
	    return @response
		end

		def self.update_profile(url, params)
			res_form_sentai = RestClient.post(url, params)
			@response = JSON.parse(res_form_sentai.body)
			log("UpdateProfile", @response)
			if @response["response_status"] == "OK" && @response.present?
      	@outh_sentai = Member.update_profile(@response)
      else
      	@outh_sentai = nil
	    end
	    return @outh_sentai
		end

	end
end