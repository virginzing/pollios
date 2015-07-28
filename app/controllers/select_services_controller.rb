class SelectServicesController < ApplicationController

  layout 'select_service'

  before_action :signed_user

  def index
    @service = current_company.decorate

    if @service.using_service.size == 0
      fail ExceptionHandler::WebForbidden
    end
  end

end
