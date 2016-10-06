module Pollios::Auth
  class WebApp < Grape::API
    resource :web_app do
      desc 'sign in Pollios app on web browser with sentai'
      params do
        requires :authen, type: String, desc: 'email for Pollios app account'
        requires :password, type: String, desc: 'password'
      end
      post '/sign_in' do
        member = Authentication::PolliosWebApp.sign_in(params)
        present :member, member, with: Pollios::V1::CurrentMemberAPI::MemberEntity
        present :api_token, member.api_tokens.first.token
      end
    end
  end
end
