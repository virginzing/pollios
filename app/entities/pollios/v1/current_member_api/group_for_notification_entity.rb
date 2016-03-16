module Pollios::V1::CurrentMemberAPI
  class GroupForNotificationEntity < Pollios::V1::BaseEntity

    expose :id, as: :group_id
    expose :name
    expose :cover, as: :avatar
    
  end
end