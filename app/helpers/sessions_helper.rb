module SessionsHelper

  def current_member
    @current_member ||= Member.find_by(auth_token: cookies[:auth_token]) if cookies[:auth_token]
  end

  def current_company
    current_member.get_company if current_member
  end

  def signed_in?
    !current_member.nil?
  end

  def signed_user
    return if current_member.present?
    store_location
    flash[:warning] = 'Please sign in before access this page.'
    redirect_to users_signin_url
  end

end
