module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from NotFound, :with => :known_error
    rescue_from Forbidden, :with => :known_error
    rescue_from MemberNotFoundHtml, :with => :known_error_html
    rescue_from MobileNotFound, :with => :mobile_not_found
    rescue_from MobileForbidden, :with => :mobile_forbidden
  end

  class NotFound < StandardError; end
  class Forbidden < StandardError; end
  class MemberNotFoundHtml < StandardError; end
  class MobileNotFound < StandardError; end
  class MobileForbidden < StandardError; end

  def known_error(ex)
    Rails.logger.error "[ExceptionHandler] Exception #{ex.class}: #{ex.message}"
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: 200
  end

  def known_error_html(ex)
    flash[:warning] = "Please sign in"
    redirect_to users_signin_path
  end

  def mobile_not_found
    render 'mobiles/errors/404'
  end

  def mobile_forbidden
    render 'mobiles/errors/403'
  end

end