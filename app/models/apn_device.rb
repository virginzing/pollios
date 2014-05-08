class ApnDevice

  def self.create_device(device_token, member_id)
    device = Apn::Device.new
    device.token = device_token
    device.app_id = Apn::App.first.id
    device.member_id = member_id
    device.api_token = generate_api_token
    device.save!
    device
  end

  def self.change_member(device_token, member_id)
    device = Apn::Device.find_by_token(device_token)
    device.member_id = member_id
    device.api_token = generate_api_token
    device.save!
    device
  end

  def self.get_access_api(device_token, member_id)
    Apn::Device.find_by_token_and_member_id(device_token, member_id)
  end

  def self.generate_api_token
    begin
      api_token = SecureRandom.hex
    end while Apn::Device.exists?(api_token: api_token)
    return api_token
  end

  def self.check_device?(member, device_token)
    if device_token.present?
      @member_device = MemberDevise.new(member, device_token)
      @device = @member_device.check_device
      @member_device.get_access_api
    else
      nil
    end
  end
  
end
