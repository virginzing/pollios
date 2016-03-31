class MemberDevice

  attr_reader :member, :device_token

  def initialize(member, device_token)
    @member = member
    @device_token = device_token
  end

  def check_device
    if member_of_device.present?
      device_update_member
    elsif current_device.present?
      member_update_device
    else
      new_device
    end
  end

  def access_api
    @access_api ||= device_token_api
  end

  private

  def device_update_member
    member_of_device.update_attributes!(api_token: ApnDevice.generate_api_token)
  end

  def member_update_device
    ApnDevice.change_member(device_token, member.id)
  end

  def new_device
    ApnDevice.create_device(device_token, member.id)
  end

  def device_token_api
    ApnDevice.access_api(device_token, member.id)
  end

  def member_of_device
    member.apn_devices.find_by(token: device_token)
  end

  def current_device
    @current_device ||= Apn::Device.find_by(token: device_token)
  end

  
  
end