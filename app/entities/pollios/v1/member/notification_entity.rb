module Pollios::V1::Member
  class NotificationEntity < Grape::Entity
    expose :id, as: :notify_id
    expose :sender

    def sender
      Pollios::V1::Shared::MemberEntity.default_pollios_member
    end
  end
end