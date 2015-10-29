module Pollios::V1::CurrentMemberAPI
  class NotificationListEntity < Pollios::V1::BaseEntity
    # expose :notifications_count, as: :total_entries
    expose :next_index

    expose :notifications_at_current_page, as: :notifications, with: NotificationEntity
  end
end
