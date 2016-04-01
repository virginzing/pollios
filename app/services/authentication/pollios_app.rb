class Authentication::PolliosApp

  def self.sign_in(params)
    sentai_respond = Authentication::Sentai.sign_in(params.merge!(app_name: 'pollios'))
    fail ExceptionHandler::UnprocessableEntity, status: 401, message: ExceptionHandler::Message::Auth::LOGIN_FAIL \
      unless sentai_respond['response_status'] == 'OK'
    
    hash = {
      'provider' => 'sentai',
      'register' => :in_app,
      'app_id' => params[:app_id]
    }
    authenticate = Authentication.new(sentai_respond.merge!(hash))
    fail ExceptionHandler::UnprocessableEntity, status: 403, message: authenticate.error_message_detail \
      unless authenticate.check_valid_member?
    ApnDevice.update_detail(authenticate.member, params[:device_token], params[:model], params[:os])

    authenticate.member
  end

  def self.sign_up(params)
    sentai_respond = Authentication::Sentai.sign_up(params.merge!(app_name: 'pollios'))
    fail ExceptionHandler::UnprocessableEntity, status: 422, message: 'Email is already registered with Pollios' \
      unless sentai_respond['response_status'] == 'OK'

    hash = {
      'provider' => 'sentai',
      'register' => :in_app,
      'app_id' => params[:app_id]
    }
    authenticate = Authentication.new(sentai_respond.merge!(hash))
    fail ExceptionHandler::UnprocessableEntity unless authenticate.activate_account?
    ApnDevice.update_detail(authenticate.member, params[:device_token], params[:model], params[:os])

    authenticate.member
  end

  def self.forgot_password(params)
    sentai_respond = Authentication::Sentai.forgot_password(params)
    fail ExceptionHandler::UnprocessableEntity, status: 404, message: 'Email address not found' \
      unless sentai_respond['response_status'] == 'OK'

    MemberMailer.delay.password_reset(Member.find_by(email: params[:email]), sentai_respond['password_reset_token'])
    { message: 'Password reset instruction was sent to your email address' }
  end

end