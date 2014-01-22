class AuthenSentaiController < ApplicationController
	protect_from_forgery :except => [:signin_sentai, :signup_sentai, :update_sentai]
	before_action :current_login?, only: [:signin]
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
		redirect_to root_url
	end

	def signin_sentai
		@login = Authenticate::Sentai.signin( IP + '/codeapp/signin.json',
			{'authen'=> sessions_params["authen"], 'password'=> sessions_params["password"], 'app_name'=> "pollios"})

		respond_to do |wants|
			if @login.present?
				session[:member_id] = @login.id
				wants.html { redirect_to index_poll_path }
				wants.json
			else
				flash[:error] = "Invalid username or password."
				wants.html { redirect_to(:back) }
				wants.json
			end
		end
  end


  def signup_sentai
  	@outh_sentai = Authenticate::Sentai.signup( IP + '/codeapp/signup.json', signup_params, "pollios")
  	respond_to do |wants|
  		if @outh_sentai["response_status"] == "OK"
  			session[:member_id] = Member.find_by(username: @outh_sentai["username"]).id
  			@member = current_member
  			flash[:success] = "Sign up sucessfully."
  			wants.html { redirect_to(home_url(current_member.username)) }
  			wants.json
  		else
  			flash[:error] = @outh_sentai["response_message"]
  			wants.html { redirect_to(:back) }
  			wants.json
  		end
  	end
  end

  def update_sentai
  	@outh_sentai = Authenticate::Sentai.update_profile( IP + '/codeapp/update_profile.json', update_profile_params)
  end


  private

	  def sessions_params
	  	params.permit(:authen, :password)
	  end

	  def signup_params
	    params.permit(:email, :password, :username, :first_name, :last_name, :avatar, :fullname)
	  end

	  def update_profile_params
	    params.permit(:name, :email, :password, :password_confirmation, :avatar, :username, :first_name, :last_name, :app_name, :sentai_id, :fullname)
	  end

end
