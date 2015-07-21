class FacebookController < ApplicationController
  protect_from_forgery :except => [:login]

  expose(:member) { @auth.member }

  def login
    @auth = Authentication.new(fb_params.merge(Hash["provider" => "facebook", "register" => :in_app]))
    if @auth.authenticated?
      @apn_device = ApnDevice.check_device?(member, fb_params[:device_token])
      # if @auth.activate_account?
      # end
    end
  end


  private

  def fb_params
    params.permit(:id, :name, :email, :user_photo, :username, :device_token, :birthday, :gender, :app_id)
  end
end
