module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from StandardError, :with => :known_error
  end

  class GroupAdminNotFound < StandardError; end
  class GroupNotFound < StandardError; end
  class MemberInGroupNotFound < StandardError; end

  class PollNotFound < StandardError; end
  class ChoiceNotFound < StandardError; end

  class NotCompanyAccount < StandardError; end

  def known_error(ex)
    Rails.logger.error "[ExceptionHandler] Exception #{ex.class}: #{ex.message}"
    if request.format.json?
      render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: 200
    else
      render :status => 404
    end
  end
end