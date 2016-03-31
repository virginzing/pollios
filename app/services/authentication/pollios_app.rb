class Authentication::PolliosApp

  def self.sign_in(params)
    sentai_respond = Authentication::Sentai.sign_in(params.merge!(app_name: 'pollios'))
    fail ExceptionHandler::UnprocessableEntity, 401 unless sentai_respond['response_status'] == 'OK'
    
    hash = {
      provider: 'sentai',
      web_login: params[:web_login],
      register: :in_app,
      app_id: params[:app_id]
    }
    authenticate = Authentication.new(sentai_respond.merge!(hash))
    fail ExceptionHandler::UnprocessableEntity, 403 unless authenticate.check_valid_member?
    ApnDevice.update_detail(authenticate.member, params[:device_token], params[:model], params[:os])

    authenticate.member
  end

end