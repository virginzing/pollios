module V1
  class ApplicationController < ::ApplicationController
    rescue_from ActionController::RoutingError, with: :not_found_handler
    rescue_from ActionController::RedirectBackError, with: :handle_redirect_error

    before_action :set_current_member

    helper_method :member_signed_in?

    private

    def not_found_handler
      render 'v1/errors/not_found', layout: 'v1/navbar_no_sidebar', status: :not_found
    end

    protected

    def set_meta(meta)
      @meta = meta

      @meta[:title] ||= 'Pollios'
      @meta[:description] ||= 'Raise your hand. Your voice matters. Join us and vote!'
      @meta[:url] ||= 'http://www.pollios.com'
      @meta[:image] ||= 'http://www.pollios.com/images/logo/1024logo.png'
    end

    def set_current_member
      @current_member ||= ::Member.where(id: session[:member_id]).first
    end

    def member_signed_in?
      !session[:member_id].nil?
    end

    def handle_redirect_error
      redirect_to root_path
    end
  end
end
