module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from NotFound, :with => :not_found
    rescue_from Forbidden, :with => :forbdden
    rescue_from UnprocessableEntity, :with => :unprocessable_entity
    rescue_from Unauthorized, :with => :unauthorized
    rescue_from MemberNotFoundHtml, :with => :known_error_html
    rescue_from MobileNotFound, :with => :mobile_not_found
    rescue_from MobileForbidden, :with => :mobile_forbidden
    rescue_from MobileSignInAlready, :with => :mobile_signin_already
    rescue_from MobileVoteQuestionnaireAlready, :with => :mobile_vote_questionnaire_already
  end

  class NotFound < StandardError; end
  class Forbidden < StandardError; end
  class UnprocessableEntity < StandardError; end
  class Unauthorized < StandardError; end
  class MemberNotFoundHtml < StandardError; end
  class MobileNotFound < StandardError; end
  class MobileForbidden < StandardError; end
  class MobileSignInAlready < StandardError; end
  class MobileVoteQuestionnaireAlready < StandardError; end

  module Message
    module Poll
      NOT_FOUND = "This poll was deleted from Pollios."
      UNDER_INSPECTION = "Many users had reported this poll to us. We've temporary removed it."
    end

    module Member
      BAN = "Your account is was terminated"
      BLACKLIST = "Your account is being suspended"
    end

    module Token
      WRONG = "You had already signed out of Pollios. Please sign in again"
    end
  end

  def not_found(ex)
    # Rails.logger.error "[ExceptionHandler] Exception #{ex.class}: #{ex.message}"
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: :not_found
  end

  def forbdden(ex)
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: :forbidden
  end

  def unprocessable_entity(ex)
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: :unprocessable_entity
  end

  def unauthorized(ex)
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: :unauthorized
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

  def mobile_signin_already
    flash[:notice] = "You already sign-in"
    redirect_to mobile_dashboard_path
  end

  def mobile_vote_questionnaire_already
    flash[:notice] = "You already vote this questionnaire."
    redirect_to mobile_dashboard_path
  end

end