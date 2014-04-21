module AuthenSentaiHelper
	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session[:return_to] = nil
	end

	def store_location
		session[:return_to] = request.fullpath
	end

	def current_login?
		if current_member
			flash[:warning] = "You already signin !"
			redirect_back_or(root_url)
		end
	end
end
