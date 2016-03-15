class Member::DeviceAction

  attr_reader :member, :device

  def initialize(member, device)
    @member = member
    @device = device

    fail ExceptionHandler::UnprocessableEntity, "This device isn't exist in your devices" unless device.member_id == member.id
  end

  def undate_info(params)
    device.update!(params)

    Member::DeviceList.new(member).all_device
  end

  def delete
    device.destroy
    
    Member::DeviceList.new(member).all_device
  end

end