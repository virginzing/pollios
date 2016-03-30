module Pollios
  class Sentai < Grape::API
    format :json
    prefix :sentai

    desc 'sign in Pollios app on mobile with sentai'
    post '/sign_in' do
    
    end

    desc 'sign up Pollios app on mobile with sentai'
    post '/sign_up' do
    
    end

    desc 'sign out Pollios app on mobile with sentai'
    post '/sign_out' do
      
    end

    desc 'forgot password Pollios app on mobile with sentai'
    post '/forgot_password' do
      
    end

    desc 'change password password Pollios app on mobile with sentai'
    post '/change_password' do
      
    end

  end
end