module Pollios::V1::Member
  class NotificationEntity < Grape::Entity
    expose :id, as: :notify_id
    expose :sender

    def sender
      
    end
  end
end