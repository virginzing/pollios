module Pollios
  class Sentai < Grape::API
    format :json
    prefix :sentai

    rescue_from ExceptionHandler::UnprocessableEntity do |e|
      e = eval(e.message)
      error!(e[:message], e[:status])
    end

    desc 'sign in Pollios app on mobile with sentai'
    params do
      requires :authen, type: String, desc: 'email for Pollios app account'
      requires :password, type: String, desc: 'password'
      requires :app_id, type: String, desc: 'Pollios app id'
      requires :device_token, type: String, desc: 'device token'

      requires :model, type: Hash do
        requires :name, type: String, desc: 'device name'
        requires :type, type: String, desc: 'device type'
        requires :version, type: String, desc: 'device version'
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
    post '/sign_up' do

    end

    desc 'forgot password Pollios app on mobile with sentai'
    post '/forgot_password' do
      
    end

    desc 'change password password Pollios app on mobile with sentai'
    post '/change_password' do
      
    end

    desc 'sign out Pollios app on mobile with sentai'
    delete '/sign_out' do

    end

  end
end