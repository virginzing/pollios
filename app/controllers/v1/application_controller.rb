module V1
  class ApplicationController < ::ApplicationController
    rescue_from ActionController::RoutingError, with: :handle_not_found
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::RedirectBackError, with: :handle_redirect_error
    rescue_from ExceptionHandler::UnprocessableEntity, with: :handle_status_422

    before_action :set_meta
    before_action :set_current_member

    helper_method :member_signed_in?

    protected

    def set_meta(meta = {})
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

    def handle_not_found
      render 'v1/errors/not_found', layout: 'v1/main', status: :not_found
    end

    def handle_redirect_error
      redirect_to root_path
    end

    def handle_status_422(e)
      flash[:type] = 'error'
      flash[:message] = e.message

      redirect_to :back
    end
  end
end
