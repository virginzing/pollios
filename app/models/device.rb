class Device < ActiveRecord::Base
  belongs_to :member

  def self.create_device(device_token, member_id)
    device = Device.new
    device.token = device_token
    device.member_id = member_id
    device.api_token = generate_api_token
    device.save!
  end

  def self.change_member(device_token, member_id)
    device =  Device.find_by_token(device_token)
    device.member_id = member_id
    device.api_token = generate_api_token
    device.save!
  end

  def self.get_access_api(device_token, member_id)
    Device.find_by_token_and_member_id(device_token, member_id)
  end

  def self.generate_api_token
    begin
      api_token = SecureRandom.hex
    end while Device.exists?(api_token: api_token)
    return api_token
  end

end
