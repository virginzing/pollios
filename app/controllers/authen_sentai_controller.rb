class AuthenSentaiController < ApplicationController
	protect_from_forgery :except => [:signin_sentai, :signup_sentai, :update_sentai]
	before_action :current_login?, only: [:signin]

  expose(:current_member_id) { session[:member_id] }

	include Authenticate

	layout "authen"

	IP = 'http://codeapp-user.herokuapp.com'

	def signin
	end

	def signup
	end

	def signout
		session[:member_id] = nil
		session[:return_to] = nil
		flash[:success] = "Signout sucessfully."
		redirect_to authen_signin_path
	end

	def signin_sentai
		@login = Authenticate::Sentai.signin( IP + '/codeapp/signin.json',
			{'authen'=> sessions_params["authen"], 'password'=> sessions_params["password"], 'app_name'=> "pollios"})

		respond_to do |wants|
			if @login.present?
        @apn_device = check_device?(@login, sessions_params["device_token"]) if sessions_params["device_token"].present?
				session[:member_id] = @login.id
				wants.html { redirect_to polls_path }
				wants.json
			else
				flash[:error] = "Invalid username or password."
				wants.html { redirect_to(:back) }
				wants.json
			end
		end
  end


  def signup_sentai
  	@response, member = Authenticate::Sentai.signup( IP + '/codeapp/signup.json', signup_params, "pollios")
    puts "response : #{response}, member : #{member}"
  	respond_to do |wants|
  		if @response["response_status"] == "OK"
        @apn_device = check_device?(member, signup_params["device_token"]) if signup_params["device_token"].present?
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
  	@outh_sentai = Authenticate::Sentai.update_profile( IP + '/codeapp/update_profile.json', update_profile_params)
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
	    params.permit(:email, :password, :username, :first_name, :last_name, :avatar, :fullname, :device_token, :birthday, :gender, :province_id)
	  end

	  def update_profile_params
	    params.permit(:name, :email, :password, :password_confirmation, :avatar, :username, :device_token, :first_name, :last_name, :app_name, :sentai_id, :fullname, :birthday, :gender, :province_id)
	  end

end
