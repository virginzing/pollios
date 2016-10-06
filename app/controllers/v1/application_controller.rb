module V1
  class ApplicationController < ::ApplicationController
    rescue_from ActionController::RoutingError, with: :not_found_handler

    private

    def not_found_handler
      render 'v1/errors/not_found', layout: 'v1/navbar_no_sidebar', status: :not_found
    end

    protected

    def set_meta(meta)
      @meta = meta

      @meta[:title] ||= 'Pollios'
      @meta[:description] ||= 'Raise your hand.'
      @meta[:url] ||= 'http://www.pollios.com'
      @meta[:image] ||= 'http://www.pollios.com/images/logo/1024logo.png'
    end
  end
end
