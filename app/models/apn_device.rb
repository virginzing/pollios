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

  def self.access_api(device_token, member_id)
    Apn::Device.find_by_token_and_member_id(device_token, member_id)
  end

  def self.generate_api_token
    api_token = nil

    loop do
      api_token = SecureRandom.hex
      break unless Apn::Device.exists?(api_token: api_token)
    end
    
    api_token
  end

  def self.check_device?(member, device_token)
    return unless device_token.present?
    @member_device = MemberDevice.new(member, device_token)
    @device = @member_device.check_device
    @member_device.access_api
  end

  def self.update_detail(member, device_token, model, os)
    return unless device_token.present?
    member_device = MemberDevice.new(member, device_token)
    member_device.check_device
    Apn::Device.find_by(token: device_token).update!(model: model, os: os)
    member_device.access_api
  end
  
end
