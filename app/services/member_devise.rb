class MemberDevise
  def initialize(member, device_token)
    @member = member
    @device_token = device_token
  end

  def member_id
    @member.id  
  end

  def device_token
    @device_token
  end

  def check_device
    if member_of_device.present?
      update_device
    elsif current_devise.present?
      change_device
    else
      new_device
    end
  end

  def get_access_api
    @access_api ||= device_token_api
  end

  private

  def update_device
    member_of_device.update_attributes!(api_token: Device.generate_api_token)
  end

  def change_device
    Device.change_member(device_token, member_id)
  end

  def new_device
    Device.create_device(device_token, member_id)
  end

  def device_token_api
    Device.get_access_api(device_token, member_id)
  end

  def member_of_device
    member_device ||= @member.devices.find_by(token: device_token)
  end

  def current_devise
    current_devise ||= Device.find_by_token(device_token)
  end

  
  
end