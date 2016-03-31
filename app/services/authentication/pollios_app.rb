class Authentication::PolliosApp

  def self.sign_in(params)
    sentai_respond = Authentication::Sentai.sign_in(params.merge!(app_name: 'pollios'))
    return { status: :unauthorized } unless sentai_respond['response_status'] == 'OK'
    
    hash = {
      provider: 'sentai',
      web_login: params[:web_login],
      register: :in_app,
      app_id: params[:app_id]
    }
    authenticate = Authentication.new(sentai_respond.merge!(hash))
    return { status: :forbidden } unless authenticate.check_valid_member?
    ApnDevice.update_detail(authenticate.member, params[:device_token], params[:model], params[:os])

    authenticate.member
  end

end