module Pollios::V1::Shared
  class MemberEntity < Pollios::V1::BaseEntity
    
    expose :id, as: :member_id
    expose :fullname, as: :name
    expose :description
    expose :get_avatar, as: :avatar
    expose :member_type_text, as: :type

    def self.default_pollios_member
      {
        member_id: 0,
        name: "Pollios System",
        avatar: "http://pollios.com/images/logo/pollios_system_notification.png",
        description: "Pollios Office"
      }
    end
  end
end