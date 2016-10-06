module Pollios::Auth
  class App < Grape::API
    desc 'sign in Pollios app on mobile with sentai'
    params do
      requires :authen, type: String, desc: 'email for Pollios app account'
      requires :password, type: String, desc: 'password'
      requires :app_id, type: String, desc: 'Pollios app id'
      optional :device_token, type: String, desc: 'device token'

      requires :model, type: Hash do
        requires :name, type: String, desc: 'device name'
        requires :type, type: String, desc: 'device type'
        requires :identifier, type: String, desc: 'device identifier'
      end

      requires :os, type: Hash do
        requires :name, type: String, desc: 'os name'
        requires :version, type: String, desc: 'os version'
      end
    end
    post '/sign_in' do
      member = Authentication::PolliosApp.sign_in(params)
      present :member, member, with: Pollios::V1::CurrentMemberAPI::MemberEntity
      present :api_token, member.api_tokens.first.token
    end

    desc 'sign up Pollios app on mobile with sentai'
    params do
      requires :email, type: String, desc: 'email for Pollios app account'
      requires :password, type: String, desc: 'password'
      requires :app_id, type: String, desc: 'Pollios app id'
      optional :device_token, type: String, desc: 'device token'

      requires :model, type: Hash do
        requires :name, type: String, desc: 'device name'
        requires :type, type: String, desc: 'device type'
        requires :identifier, type: String, desc: 'device identifier'
      end

      requires :os, type: Hash do
        requires :name, type: String, desc: 'os name'
        requires :version, type: String, desc: 'os version'
      end
    end
    post '/sign_up' do
      member = Authentication::PolliosApp.sign_up(params)
      present :member, member, with: Pollios::V1::CurrentMemberAPI::MemberEntity
      present :api_token, member.api_tokens.first.token
    end

    desc 'forgot password Pollios app on mobile with sentai'
    params do
      requires :email, type: String, desc: 'email for Pollios app account'
    end
    post '/forgot_password' do
      Authentication::PolliosApp.forgot_password(params)
    end

    desc 'change password password Pollios app on mobile with sentai'
    params do
      requires :email, type: String, desc: 'email for Pollios app account'
      requires :old_password, type: String, desc: 'old  password Pollios app'
      requires :new_password, type: String, desc: 'new password Pollios app'
    end
    post '/change_password' do
      error!('401 Unauthorized', 401) unless current_member
      error!('401 Unauthorized: invalid email', 401) unless current_member.email == params[:email]
      Authentication::PolliosApp.change_password(params)
    end

    desc 'sign out Pollios app on mobile with sentai'
    delete '/sign_out_all_device' do
      error!('401 Unauthorized', 401) unless current_member
      Authentication::PolliosApp.sign_out_all_device(current_member)
    end
  end
end
