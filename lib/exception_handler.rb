module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from NotFound, with: :not_found
    rescue_from Deleted, with: :not_found
    rescue_from Forbidden, with: :forbidden
    rescue_from UnprocessableEntity, with: :unprocessable_entity
    rescue_from Unauthorized, with: :unauthorized
    rescue_from NotAcceptable, with: :not_acceptable
    rescue_from Maintenance, with: :maintenance
    rescue_from MemberNotFoundHtml, with: :known_error_html
    rescue_from MobileNotFound, with: :mobile_not_found
    rescue_from MobileForbidden, with: :mobile_forbidden
    rescue_from MobileSignInAlready, with: :mobile_signin_already
    rescue_from MobileVoteQuestionnaireAlready, with: :mobile_vote_questionnaire_already
    rescue_from WebForbidden, with: :web_forbidden
    rescue_from WebNotFound, with: :web_not_found
    rescue_from CustomError, with: :custom_error
  end

  class NotFound < StandardError; end
  class Deleted < StandardError; end
  class Forbidden < StandardError; end
  class UnprocessableEntity < StandardError; end
  class Unauthorized < StandardError; end
  class NotAcceptable < StandardError; end
  class Maintenance < StandardError; end
  class MemberNotFoundHtml < StandardError; end
  class MobileNotFound < StandardError; end
  class MobileForbidden < StandardError; end
  class MobileSignInAlready < StandardError; end
  class MobileVoteQuestionnaireAlready < StandardError; end
  class WebForbidden < StandardError; end
  class WebNotFound < StandardError; end
  class CustomError < StandardError; end

  module Message
    module Poll
      NOT_FOUND = 'Poll not found.'
      UNDER_INSPECTION = "Many users had reported this poll to us. We've temporary removed it."
      DELETED = 'This poll was deleted from Pollios.'
      CLOSED = 'This poll is already closed.'
      EXPIRED = 'This poll was already expired.'
      POINT_ZERO = 'Poll to public 0 left.'
      VOTED = 'You had already voted this poll.'
      OUTSIDE_GROUP = "You're not in group. Please join this group then you can see this poll."
    end

    module PollSeries
      NOT_FOUND = 'Feedback not found.'
      DELETED = 'Feedback was deleted from Pollios.'
      CLOSED = 'Feedback was closed.'
    end

    module Member
      BAN = 'This account is permanently banned from Pollios.'
      BLACKLIST = 'This account is being suspended.'
      NOT_FOUND = 'Member not found.'
      POINT_ZERO = "You don't have any public poll quota"
    end

    module Comment
      NOT_FOUND = 'Comment not found.'
    end

    module Token
      WRONG = 'You had already signed out of Pollios. Please sign in again.'
      INVALID = WRONG
    end

    module Auth
      LOGIN_FAIL = 'Invalid email or password.'
    end

    module Maintenance
      OPEN = 'Maintenance Mode.'
    end

    module Choice
      NOT_FOUND = 'Choice not found.'
    end

    module Group
      NOT_FOUND = 'Group not found.'
      NOT_IN_GROUP = "You're not in this group."
      MEMBER_NOT_IN_GROUP = 'This user no longer this group.'
      NOT_ADMIN = "You're not an admin of group."
      ADMIN = 'This user had already admin.'
    end

    module Reward
      NOT_FOUND = 'Reward not found.'
      DELETED = 'This reward was deleted from Pollios.'
    end

    module Campaign
      NOT_FOUND = 'Campaign not found.'
      DELETED = 'This campaign was deleted from Pollios.'
    end
  end

  def not_found(ex)
    if request.format.html?
      render 'web/errors/404', layout: false
    else
      render json: Hash['response_status' => 'ERROR', 'response_message' => ex.message], status: :not_found
    end
  end

  def forbidden(ex)
    if request.format.html?
      render 'web/errors/403', layout: false
    else
      render json: Hash['response_status' => 'ERROR', 'response_message' => ex.message], status: :forbidden
    end
  end

  def unprocessable_entity(ex)
    render json: Hash['response_status' => 'ERROR', 'response_message' => ex.message], status: :unprocessable_entity
  end

  def custom_error(ex)
    render json:  Hash['response_status' => 'ERROR', 'response_message' => ex.message, 'alert_message' => ex.message], 
           status: :unprocessable_entity
  end

  def unauthorized(ex)
    render json: Hash['response_status' => 'ERROR', 'response_message' => ex.message], status: :unauthorized
  end

  def not_acceptable(ex)
    render json: Hash['response_status' => 'ERROR', 'response_message' => ex.message], status: :not_acceptable
  end

  def maintenance(ex)
    render json: Hash['response_status' => 'ERROR', 'response_message' => ex.message], status: :service_unavailable
  end

  def web_forbidden(_)
    render 'web/errors/403', layout: false
  end

  def web_not_found(_)
    render 'web/errors/404', layout: false
  end

  def known_error_html(_)
    flash[:warning] = 'Please sign in.'
    redirect_to users_signin_path
  end

  def site_not_found
    render 'mobiles/errors/404'
  end

  def mobile_not_found
    render 'mobiles/errors/404'
  end

  def mobile_forbidden
    render 'mobiles/errors/403'
  end

  def mobile_signin_already
    flash[:notice] = 'You already sign-in.'
    redirect_to mobile_dashboard_path
  end

  def mobile_vote_questionnaire_already
    flash[:notice] = 'You already vote this questionnaire.'
    redirect_to mobile_dashboard_path
  end

end
