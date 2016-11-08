class WebApp::Authentication
  attr_reader :failed, :error_message

  def sign_in(email, password)
    sign_in_params = { authen: email, password: password, app_name: 'pollios_web_app' }
    sentai_respond = ::Authentication::Sentai.sign_in(sign_in_params)

    @failed = sentai_respond['response_status'] != 'OK'
    return nil if @failed

    authentication = ::Authentication.new(sentai_respond)
    @failed = !authentication.check_valid_member?
    return nil if @failed

    authentication.member
  end

  def sign_up(email, password)
    sign_up_params = { email: email, password: password, app_name: 'pollios_web_app' }
    sentai_respond = ::Authentication::Sentai.sign_up(sign_up_params)

    @failed = sentai_respond['response_status'] != 'OK'
    @error_message = ::Authentication::PolliosApp.response_message(sentai_respond)
    return nil if @failed

    authentication = ::Authentication.new(sentai_respond)
    update_profile(authentication.member)

    authentication.member
  end

  def failed?
    @failed
  end

  def update_profile(member)
    member.update!(
      fullname: member.email.split('@').first \
      , description: 'Pollios User (via Pollios Web)'
    )
  end
end
