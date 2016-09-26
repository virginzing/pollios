class Authentication::PolliosApp
  include Authentication::DeviceIdentifier

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
    ApnDevice.update_detail(authenticate.member, params[:device_token] \
      , model_identify(params), os_identify(params))

    authenticate.member
  end

  def self.sign_up(params)
    sentai_respond = Authentication::Sentai.sign_up(params.merge!(app_name: 'pollios'))
    fail ExceptionHandler::UnprocessableEntity, status: 422, message: authenticate.error_message_detail \
      unless sentai_respond['response_status'] == 'OK'

    hash = {
      'provider' => 'sentai',
      'register' => :in_app,
      'app_id' => params[:app_id]
    }
    authenticate = Authentication.new(sentai_respond.merge!(hash))
    fail ExceptionHandler::UnprocessableEntity unless authenticate.activate_account?
    ApnDevice.update_detail(authenticate.member, params[:device_token] \
      , model_identify(params), os_identify(params))

    authenticate.member
  end

  def self.forgot_password(params)
    sentai_respond = Authentication::Sentai.forgot_password(params)
    fail ExceptionHandler::UnprocessableEntity, status: 404, message: 'Email address not found' \
      unless sentai_respond['response_status'] == 'OK'

    MemberMailer.delay.password_reset(Member.find_by(email: params[:email]), sentai_respond['password_reset_token'])
    { message: 'Password reset instruction was sent to your email address' }
  end

  def self.change_password(params)
    sentai_respond = Authentication::Sentai.change_password(params)
    fail ExceptionHandler::UnprocessableEntity, status: 422, message: sentai_respond['response_message'] \
      unless sentai_respond['response_status'] == 'OK'

    { message: sentai_respond['response_message'] }
  end

  def self.sign_out_all_device(member)
    member.api_tokens.delete_all

    nil
  end

  def self.os_identify(params)
    { 
      name: OS[params[:os][:name].to_sym] || UNKNOWN,
      version: params[:os][:version]
    }
  end

  def self.model_identify(params)
    {
      name: params[:model][:name],
      type: params[:model][:type],
      version: model_version_identify(params)
    }
  end

  def self.model_version_identify(params)
    return UNKNOWN unless os_identify(params)[:name] == 'iOS'

    APPLE[params[:model][:identifier].to_sym] || UNKNOWN
  end

end