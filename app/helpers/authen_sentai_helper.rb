module AuthenSentaiHelper

	def redirect_back_or(default)
		redirect_to cookies[:return_to] || default
		cookies.delete(:return_to)
	end

	def store_location
    cookies[:return_to] = if request.get?
      request.fullpath
    else
      request.referer
    end
  end

	def redirect_back(default)
		return_to_url = cookies[:return_to] || default
    cookies.delete(:return_to)
    return return_to_url
	end

	def current_login?
		if current_member
			flash[:warning] = "You already signin !"
			redirect_back_or root_url
		end
	end

end
