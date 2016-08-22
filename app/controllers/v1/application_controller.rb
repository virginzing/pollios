module V1
  class ApplicationController < ::ApplicationController
    # rescue_from ArgumentError, with: :not_found_handler
    rescue_from ActionController::RoutingError, with: :not_found_handler

    private

    def not_found_handler
      render 'v1/errors/not_found', layout: 'v1/navbar_no_sidebar'
    end
  end
end
