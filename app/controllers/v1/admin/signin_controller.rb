module V1::Admin
  class SigninController < ApplicationController
    layout 'v1/navbar_no_sidebar'

    def get
      render 'get'
      session.delete('flash_message')
    end

    def post
      credential = params.permit(:email,:password)
      if credential[:email] == '' || credential[:password] == ''
        session[:flash_message] = 'Incorrect email or password.'
        redirect_to :back
      end
    end
  end
end
