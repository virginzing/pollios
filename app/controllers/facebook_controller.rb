class FacebookController < ApplicationController

  protect_from_forgery :except => [:login]
  expose(:get_stats_all) { @member.get_stats_all }
  
  def login
    @member = Member.facebook(fb_params)
    if @member.present?
      @apn_device = check_device?(@member, fb_params[:device_token]) if fb_params[:device_token].present?
      @stats_all = @member.get_stats_all
    end
  end


  private

  def fb_params
    params.permit(:id, :name, :email, :user_photo, :username, :device_token, :birthday, :gender, :province_id)
  end
end
