class AuthenSentaiController < ApplicationController
	protect_from_forgery :except => [:new_sigin_sentai, :signin_sentai, :signup_sentai, :update_sentai, :change_password, :signup_sentai_via_company, :multi_signup_via_company]
	# before_action :current_login?, only: [:signin]
  # before_action :compress_gzip, only: [:signin_sentai, :signup_sentai]
  # before_filter :authenticate_admin!, :redirect_unless_admin, only: :signup

  before_action :set_current_member,  only: [:signout_all_device]

  expose(:current_member_id) { session[:member_id] }
  expose(:member) { @auth.member }

	include Authenticate


	def signin
    session[:activate_email] = nil
    session[:activate_id] = nil
    render layout: "new_login"
	end

	def signup
    render layout: "new_signup"
	end

  def signup_brand
    render layout: "new_signup"
  end

  def signup_company
    render layout: "signup_company"
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
    cookies.delete(:auth_token)
    cookies.delete(:return_to)
		flash[:success] = "Signout sucessfully."
		redirect_to users_signin_url
	end

  def signout_all_device
    @current_member.api_tokens.delete_all
    @no_content = Hash["response_status" => "OK"]

    render json: @no_content, status: :ok
  end

  def new_sigin_sentai
    @response = Authenticate::Sentai.signin(sessions_params.merge!(Hash["app_name" => "pollios"]))
    respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "web_login" => params[:web_login], "register" => :in_app]))

      if @response["response_status"] == "OK"
         @login = true
        if @auth.member.company? || AccessWeb.with_company(member.id).present?
          @access_web = true

          if sessions_params[:remember_me]
            cookies.permanent[:auth_token] = member.auth_token
          else
            cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
          end

          @feedback = @auth.member.get_company.using_service.include?("Feedback")
          @internal_survey = @auth.member.get_company.using_service.include?("Survey")

          wants.html
          wants.json
          wants.js
        else
          flash[:warning] = "Only admin of company"
          wants.js
        end
      else
        @login = false
        flash[:warning] = ExceptionHandler::Message::Auth::LOGIN_FAIL
        wants.json
        wants.js
      end
    end
  end

	def signin_sentai

		@response = Authenticate::Sentai.signin(sessions_params.merge!(Hash["app_name" => "pollios"]))
    # puts "response => #{@response}"
		respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "web_login" => params[:web_login], "register" => :in_app, "app_id" => params[:app_id]]))
			if @response["response_status"] == "OK"
        if @auth.check_valid_member?
          # fail ExceptionHandler::UnprocessableEntity, "This account can't use this app. Please sign-in at Pollios.com" if member.company?
          @apn_device = ApnDevice.check_device?(member, sessions_params["device_token"])
          @login = true
          @waiting_info = WaitingList.new(@auth.member).get_info

          if params[:web_login].present?
            if sessions_params[:remember_me]
              cookies.permanent[:auth_token] = member.auth_token
            else
              cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
            end
          end
          wants.html
          wants.json { render status: :ok }
          wants.js
        else
          wants.html
          wants.json { render status: :forbidden }
          wants.js
        end
			else
        @login = false
				flash[:warning] = ExceptionHandler::Message::Auth::LOGIN_FAIL
				wants.html { redirect_to(:back) }
				wants.json { render status: :unauthorized }
        wants.js
			end
		end

  end

  def signup_sentai
  	@response = Authenticate::Sentai.signup(signup_params.merge!(Hash["app_name" => "pollios"]))
    # puts "response : #{@response}"
  	respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => signup_params["member_type"], 
        "approve_brand" => signup_params["approve_brand"], "new_company" => params[:new_company], "address" => signup_params["address"], 
        "company_id" => signup_params["company_id"], "select_service" => signup_params["select_service"], "register" => :in_app, "app_id" => signup_params[:app_id] ])
      )

  		if @response["response_status"] == "OK"
        @apn_device = ApnDevice.check_device?(member, signup_params["device_token"])
        if @auth.activate_account?

          cookies[:auth_token] = { value: member.auth_token, expires: 6.hour.from_now }
          # session[:member_id] = member.id
          flash[:success] = "Sign up sucessfully."
          @signup = true
          
          @waiting_info = WaitingList.new(member).get_info

          if params[:new_company]
            @feedback = @auth.member.get_company.using_service.include?("Feedback")
            @internal_survey = @auth.member.get_company.using_service.include?("Survey")
          end

          wants.html
          wants.json
          wants.js
        else
          @signup = false
          @waiting = true
          session[:activate_email] = member.email
          session[:activate_id] = member.id

          if @auth.member_type == "3"
            @signup_company = true
            cookies[:waiting_approve] = { value: 'waiting_approve', expires: 5.seconds.from_now }
            flash[:warning] = "Please waiting for approve."
          else
            flash[:warning] = "This account is not activate yet."
          end

          wants.html
          wants.json
          wants.js
        end
  		else
        @signup = false

  			flash[:error] = @response["response_message"].values.flatten.join(", ")
        @flash_error = flash[:error]

        p @flash_error

  			wants.html { redirect_to(:back) }
  			wants.json { render status: 422 }
        wants.js
  		end
  	end
  end

  def signup_sentai_via_company
    @response = Authenticate::Sentai.signup(signup_company_params.merge!(Hash["app_name" => "pollios"]))
    respond_to do |wants|
      @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => signup_company_params["member_type"], "redeemer" => signup_company_params["redeemer"] ,"company_id" => signup_company_params["company_id"], "fullname" => signup_company_params["fullname"], "register" => :in_app ]))
      if @response["response_status"] == "OK"
        @auth.member
        flash[:success] = "Create sucessfully."
        @signup = true
        @feedback_redeemer = false

        if signup_company_params["feedback"].present? && signup_company_params["company_id"].present?
          @feedback_redeemer = true
          wants.html { redirect_to redeemers_path }
        end

        wants.html { redirect_to company_members_path }
        wants.json
        wants.js
      else
        @signup = false
        flash[:error] = @response["response_message"]
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

        MemberMailer.delay.password_reset(Member.find_by_email(forgotpassword_params["email"]), @password_reset_token)
        wants.js
        wants.json { render json: Hash["response_status" => "OK", "response_message" => "Email sent with password reset instructions"] }
      else
        @forgot_password = false
        wants.js
        wants.json { render json: Hash["response_status" => "ERROR", "response_message" => "Email not found"], status: :not_found }
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
        format.json { render status: 201 }
      else
        @change_password = false
        @response_message = @response["response_message"]
        format.js
        format.json { render status: 422 }
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

  def waiting_approve
    if cookies[:waiting_approve]
      render layout: "waiting_approve"
    else
      redirect_to root_path
    end
  end

  private

	  def sessions_params
	  	params.permit(:authen, :password, :device_token, :remember_me, :web_login, :app_id)
	  end

    def forgotpassword_params
      params.permit(:email)
    end

    def changepassword_params
      params.permit(:email, :old_password, :new_password, :re_new_password)
    end

    def resetpassword_params
      params.permit(:new_password, :password_reset_token)
    end

    def signup_company_params 
      params.require(:member).permit(:company_id, :member_type, :email, :password, :password_confirmation, :redeemer, :feedback, :fullname)
    end

	  def signup_params
	    params.permit(:format, :authen_sentai, :app_id, :approve_brand, :email, :password, :username, :first_name, :last_name, :avatar, :fullname, :device_token, :birthday, :gender, :member_type, :key_color, :address, :company_id, :select_service => [])
	  end

	  def update_profile_params
	    params.permit(:app_id, :name, :email, :password, :password_confirmation, :avatar, :username, :device_token, :first_name, :last_name, :app_name, :sentai_id, :fullname, :birthday, :gender, :member_type)
	  end

end
