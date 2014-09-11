module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from NotFound, :with => :known_error
    rescue_from Forbidden, :with => :known_error
  end

  class NotFound < StandardError; end
  class Forbidden < StandardError; end


  def known_error(ex)
    Rails.logger.error "[ExceptionHandler] Exception #{ex.class}: #{ex.message}"
    render json: Hash["response_status" => "ERROR", "response_message" => ex.message], status: 200
  end
end