class WebApp::Authentication
  attr_reader :sign_in_failed

  def sign_in(email, password)
    sign_in_params = { authen: email, password: password, app_name: 'pollios_web_app' }
    sentai_respond = ::Authentication::Sentai.sign_in(sign_in_params)

    @sign_in_failed = sentai_respond['response_status'] != 'OK'
    return nil if @sign_in_failed

    authentication = ::Authentication.new(sentai_respond)
    @sign_in_failed = !authentication.check_valid_member?
    return nil if @sign_in_failed

    authentication.member
  end

  def sign_in_failed?
    @sign_in_failed
  end
end
