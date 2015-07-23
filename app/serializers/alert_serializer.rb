class AlertSerializer
  attr_reader :response_status, :alert_message

  def initialize(attributes)
    @response_status = attributes[:response_status]
    @alert_message = attributes[:alert_message]
  end

  def to_json
    Hash["response_status" => @response_status, "alert_message" => @alert_message]
  end


end
