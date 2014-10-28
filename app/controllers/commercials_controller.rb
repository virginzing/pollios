class CommercialsController < ApplicationController
  
  layout 'admin'
  
  # skip_before_action :verify_authenticity_token
  before_filter :authenticate_admin!, :redirect_unless_admin

  def index
    @commercials = Member.with_member_type(:brand, :company)
  end

  def new
    
  end

  def edit
    
  end

end
