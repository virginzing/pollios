class AuthenSentaiController < ApplicationController
	protect_from_forgery :except => [:signin_sentai, :signup_sentai, :update_sentai]
	before_action :current_login?, only: [:signin]
  before_action :compress_gzip, only: [:signin_sentai]
  before_filter :authenticate_admin!, :redirect_unless_admin, only: :signup

  expose(:current_member_id) { session[:member_id] }
  expose(:member) { @auth.member }
  expose(:get_stats_all) { member.get_stats_all }

	include Authenticate


	def signin
    render layout: "login"
	end

	def signup
    render layout: "signup"
	end

	def signout
		session[:member_id] = nil
		session[:return_to] = nil
		flash[:success] = "Signout sucessfully."
		redirect_to authen_signin_path
	end

	def signin_sentai

		@response = Authenticate::Sentai.signin(sessions_params.merge!(Hash["app_name" => "pollios"]))
    
		respond_to do |wants|
			if @response["response_status"] == "OK"
        @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai"]))
        @apn_device = check_device?(member, sessions_params["device_token"]) if sessions_params["device_token"].present?

				session[:member_id] = member.id
				wants.html { redirect_back_or polls_path }
				wants.json
			else
				flash[:error] = "Invalid username or password."
				wants.html { redirect_to(:back) }
				wants.json
			end
		end

  end


  def signup_sentai

  	@response = Authenticate::Sentai.signup(signup_params.merge!(Hash["app_name" => "pollios"]))
    # puts "response : #{response}, member : #{@member}"
  	respond_to do |wants|
  		if @response["response_status"] == "OK"
        @auth = Authentication.new(@response.merge!(Hash["provider" => "sentai", "member_type" => signup_params["member_type"]]))
        @apn_device = check_device?(@member, signup_params["device_token"]) if signup_params["device_token"].present?
        puts "apn_device => #{@apn_device}"
  			session[:member_id] = member.id
  			flash[:success] = "Sign up sucessfully."
  			wants.html { redirect_to root_url }
  			wants.json
  		else
  			flash[:error] = @response["response_message"]
  			wants.html { redirect_to(:back) }
  			wants.json
  		end
  	end
  end

  def update_sentai
  	@response, @member = Authenticate::Sentai.update_profile(update_profile_params)
  end

  def check_device?(member, device_token)
    member_device = member.apn_devices.find_by(token: device_token)
    find_device = APN::Device.find_by_token(device_token)

    if member_device.present?
      api_token = Device.generate_api_token
      member_device.api_token = api_token
      member_device.save!
      device = member_device
    elsif find_device.present?
      device = Device.change_member(device_token, member.id)
    else
      device = Device.create_device(device_token, member.id)
    end
    device
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
