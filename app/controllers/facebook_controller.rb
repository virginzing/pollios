class FacebookController < ApplicationController
  protect_from_forgery :except => [:login]
  # before_action :compress_gzip, only: [:login]

  expose(:member) { @auth.member }
  expose(:get_stats_all) { member.get_stats_all }

  def login
    @auth = Authentication.new(fb_params.merge(Hash["provider" => "facebook"]))
    if @auth.authenticated?
      @apn_device = ApnDevice.check_device?(member, fb_params[:device_token])
      # if @auth.activate_account?
      # end
    end
  end


  private

  def fb_params
    params.permit(:id, :name, :email, :user_photo, :username, :device_token, :birthday, :gender)
  end
end
