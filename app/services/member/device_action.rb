class Member::DeviceAction
  include Member::Private::DeviceAction

  attr_reader :member, :device

  def initialize(member, device = nil)
    @member = member
    @device = device

    return unless device.present?

    fail ExceptionHandler::UnprocessableEntity, "This device isn't exist in your devices" unless device.member_id == member.id
  end

  def create(params)
    process_create(params)
  end

  def update_info(params)
    process_update_info(params)
  end

  def delete
    process_delete
  end

end