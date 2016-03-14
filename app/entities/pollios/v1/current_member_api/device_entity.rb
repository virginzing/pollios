module Pollios::V1::CurrentMemberAPI
  class DeviceEntity < Pollios::V1::BaseEntity

    expose :id, as: :device_id
    expose :token, as: :device_token
    expose :name
    expose :receive_notification

  end
end