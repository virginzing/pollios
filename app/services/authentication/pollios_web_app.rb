class Authentication::PolliosWebApp
  def self.sign_in(params)
    sentai_respond = Authentication::Sentai.sign_in(params.merge!(app_name: 'pollios_web_app'))
    fail \
      ExceptionHandler::UnprocessableEntity, \
      status: 401, \
      message: ExceptionHandler::Message::Auth::LOGIN_FAIL \
      unless sentai_respond['response_status'] == 'OK'

    authenticate = Authentication.new(sentai_respond)
    fail \
      ExceptionHandler::UnprocessableEntity, \
      status: 403, \
      message: authenticate.error_message_detail \
      unless authenticate.check_valid_member?

    authenticate.member
  end
end
