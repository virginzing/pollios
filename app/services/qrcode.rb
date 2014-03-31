class Qrcode
  def initialize(params)
    @params = params
  end

  def poll_id
    @params["id"]
  end

  def qrcode_key
    @params["qrcode_key"]
  end

  def poll_detail
    find_poll if poll_available
  end

  private

  def find_poll
    @poll ||= Poll.find_by_id(poll_id)
  end

  def poll_available
    find_poll.present? && find_poll.qrcode_key == qrcode_key
  end
  
end