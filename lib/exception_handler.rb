module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from StandardError, :with => :known_error
  end

  class GroupAdminNotFound < StandardError; end
  class GroupNotFound < StandardError; end
  class MemberInGroupNotFound < StandardError; end

  def known_error(ex)
    Rails.logger.error "[ExceptionHandler] Exception #{ex.class}: #{ex.message}"
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: 404
  end

end