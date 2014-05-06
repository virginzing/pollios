class FacebookController < ApplicationController
  protect_from_forgery :except => [:login]

  expose(:member) { @auth.member }
  expose(:get_stats_all) { member.get_stats_all }
  
  def login
    @auth = Authentication.new(fb_params.merge(Hash["provider" => "facebook"]))
    if @auth.authenticated?
      if fb_params[:device_token].present?
        @member_device = MemberDevise.new(member, fb_params[:device_token])
        @device = @member_device.check_device
        @apn_device = @member_device.get_access_api
      end
    end
  end


  private

  def fb_params
    params.permit(:id, :name, :email, :user_photo, :username, :device_token, :birthday, :gender, :province_id)
  end
end