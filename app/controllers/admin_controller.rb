class AdminController < ApplicationController
  layout 'admin'
  
  before_filter :authenticate_admin!, :redirect_unless_admin

  def dashboard
    
  end

  def invite
    @invite_codes = InviteCode.joins(:company).select("invite_codes.*, companies.name as company_name")
  end

  def signout
    sign_out current_admin
    redirect_to root_url
  end
end
