class SelectServicesController < ApplicationController

  layout 'select_service'
  
  skip_before_action :verify_authenticity_token
  
  before_action :signed_user

  def index
    @service = @current_member.get_company.using_service
  end

end
