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

    @failed = invalid_email?(email)
    @error_message = 'Invalid e-mail' if @failed
    return nil if @failed

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
    Member::SettingUpdate.new(member).profile(
      name: member.email.split('@').first \
      , description: 'Pollios User (via Pollios Web)'
    )
  end

  def invalid_email?(email)
    pattern = /^[a-z0-9]+([\.|_|-][-a-z0-9_]+)*_?@([a-z0-9_][-a-z0-9_]*(\.[-a-z0-9_]+)*\.(aero|arpa|biz|com|coop|edu|gov|info|int|mil|museum|name|net|org|pro|travel|mobi|[a-z][a-z])|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(:[0-9]{1,5})?$/i

    pattern.match(email).nil?
  end
end
