class AuthenSentaiController < ApplicationController
	protect_from_forgery :except => [:signin_sentai, :signup_sentai, :update_sentai, :change_password]
	# before_action :current_login?, only: [:signin]
  # before_action :compress_gzip, only: [:signin_sentai, :signup_sentai]
  # before_filter :authenticate_admin!, :redirect_unless_admin, only: :signup

  expose(:current_member_id) { session[:member_id] }
  expose(:member) { @auth.member }
  expose(:get_stats_all) { member.get_stats_all }

	include Authenticate


	def signin
    session[:activate_email] = nil
    session[:activate_id] = nil
    render layout: "new_login"
	end

	def signup
    render layout: "new_signup"
	end

  def forgot_pwd
    render layout: "forgot_password"
  end

  def reset_pwd
    render layout: "reset_password"
  end

	def signout
		session[:member_id] = nil
		session[:return_to] = nil
		flash[:success] = "Signout sucessfully."
		redirect_to users_signin_url
	end

	def signin_sentai

		@response = Authenticate::Sentai.signin(sessions_params.merge!(Hash["app_name" => "pollios"]))
    # puts "signin => #{@response}"
		respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai"]))
			if @response["response_status"] == "OK" && @auth.authenticated?
        if @auth.activate_account?
          @apn_device = ApnDevice.check_device?(member, sessions_params["device_token"])
          @login = true
          session[:member_id] = member.id
          wants.html { redirect_back_or polls_path }
          wants.json
          wants.js
        else
          @login = false
          @waiting = true
          session[:activate_email] = member.email
          session[:activate_id] = member.id
          flash[:warning] = "This account is not activate yet."
          wants.html
          wants.json
          wants.js
        end
			else
        @login = false
				flash[:warning] = "Invalid email or password."
				wants.html { redirect_to(:back) }
				wants.json
        wants.js
			end
		end

  end


  def signup_sentai
  	@response = Authenticate::Sentai.signup(signup_params.merge!(Hash["app_name" => "pollios"]))
    puts "response : #{@response}"
  	respond_to do |wants|
  		if @response["response_status"] == "OK"
        @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => signup_params["member_type"]]))
        if @auth.activate_account?
          @apn_device = ApnDevice.check_device?(member, signup_params["device_token"])
          session[:member_id] = member.id
          flash[:success] = "Sign up sucessfully."
          @signup = true
          wants.html { redirect_to dashboard_path }
          wants.json
          wants.js
        else
          @signup = false
          session[:activate_email] = member.email
          session[:activate_id] = member.id
          flash[:warning] = "This account is not activate yet."
          wants.html
          wants.json
          wants.js
        end
  		else
        @signup = false
  			flash[:error] = @response["response_message"]
        # puts "#{flash[:error].class}"
        @flash_error = flash[:error]

  			wants.html { redirect_to(:back) }
  			wants.json
        wants.js
  		end
  	end
  end

  def forgot_password
    respond_to do |wants|
      @response = Authenticate::Sentai.forgot_password(forgotpassword_params)
      puts "response : #{@response}"
      if @response["response_status"] == "OK"
        @forgot_password = true
        @password_reset_token = @response["password_reset_token"]

        MemberMailer.password_reset(Member.find_by_email(forgotpassword_params["email"]), @password_reset_token).deliver
        wants.js
      else
        @forgot_password = false
        wants.js
      end
    end
  end

  def change_password
    respond_to do |format|
      @response = Authenticate::Sentai.change_password(changepassword_params)
      puts "response : #{@response}"
      if @response["response_status"] == "OK"
        @change_password = true
        @response_message = @response["response_message"]
        format.js
      else
        @change_password = false
        @response_message = @response["response_message"]
        format.js
      end
    end
    
  end

  def reset_password
    respond_to do |wants|
      @response = Authenticate::Sentai.reset_password(resetpassword_params)
      puts "response : #{@response}"
      if @response["response_status"] == "OK"
        @reset_password = true
        flash[:success] = "Password has been reset."
        wants.js
      else
        @reset_password = false
        wants.js
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

    def forgotpassword_params
      params.permit(:email)
    end

    def changepassword_params
      params.permit(:sentai_id, :old_password, :new_password)
    end

    def resetpassword_params
      params.permit(:new_password, :password_reset_token)
    end

	  def signup_params
	    params.permit(:email, :password, :username, :first_name, :last_name, :avatar, :fullname, :device_token, :birthday, :gender, :province_id, :member_type, :key_color)
	  end

	  def update_profile_params
	    params.permit(:name, :email, :password, :password_confirmation, :avatar, :username, :device_token, :first_name, :last_name, :app_name, :sentai_id, :fullname, :birthday, :gender, :province_id, :member_type)
	  end

end
