class AuthenSentaiController < ApplicationController
	protect_from_forgery :except => [:signin_sentai, :signup_sentai, :update_sentai]
	# before_action :current_login?, only: [:signin]
  # before_action :compress_gzip, only: [:signin_sentai, :signup_sentai]
  # before_filter :authenticate_admin!, :redirect_unless_admin, only: :signup

  expose(:current_member_id) { session[:member_id] }
  expose(:member) { @auth.member }
  expose(:get_stats_all) { member.get_stats_all }

	include Authenticate


	def signin
    render layout: "new_login"
	end

	def signup
    render layout: "new_signup"
	end

	def signout
		session[:member_id] = nil
		session[:return_to] = nil
		flash[:success] = "Signout sucessfully."
		redirect_to users_signin_url
	end

	def signin_sentai

		@response = Authenticate::Sentai.signin(sessions_params.merge!(Hash["app_name" => "pollios"]))
    puts "signin => #{@response}"
		respond_to do |wants|
			if @response["response_status"] == "OK"
        @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai"]))
        @apn_device = ApnDevice.check_device?(member, sessions_params["device_token"])

				session[:member_id] = member.id
				wants.html { redirect_back_or polls_path }
				wants.json
			else
				flash[:warning] = "Invalid username or password."
				wants.html { redirect_to(:back) }
				wants.json
			end
		end

  end


  def signup_sentai

  	@response = Authenticate::Sentai.signup(signup_params.merge!(Hash["app_name" => "pollios"]))
    puts "response : #{@response}"
  	respond_to do |wants|
  		if @response["response_status"] == "OK"
        @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => signup_params["member_type"]]))
        @apn_device = ApnDevice.check_device?(member, signup_params["device_token"])
  			session[:member_id] = member.id
  			flash[:success] = "Sign up sucessfully."
  			wants.html { redirect_to root_url }
  			wants.json
  		else
  			flash[:error] = @response["response_message"]
        puts "#{flash[:error]}"
        @flash_error = flash[:error]
  			wants.html { redirect_to(:back) }
  			wants.json
  		end
  	end
  end

  def update_sentai
  	@response, @member = Authenticate::Sentai.update_profile(update_profile_params)
  end

  private

	  def sessions_params
	  	params.permit(:authen, :password, :device_token)
	  end

	  def signup_params
	    params.permit(:email, :password, :username, :first_name, :last_name, :avatar, :fullname, :device_token, :birthday, :gender, :province_id, :member_type)
	  end

	  def update_profile_params
	    params.permit(:name, :email, :password, :password_confirmation, :avatar, :username, :device_token, :first_name, :last_name, :app_name, :sentai_id, :fullname, :birthday, :gender, :province_id, :member_type)
	  end

end
