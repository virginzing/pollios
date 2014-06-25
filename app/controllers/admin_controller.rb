class AdminController < ApplicationController
  layout 'admin'
  
  before_filter :authenticate_admin!, :redirect_unless_admin

  def dashboard
    
  end

  def invite
    
  end
end
