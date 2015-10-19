module Pollios::V1::Member
  class NotificationListEntity < Grape::Entity
    expose :notifications_count, as: :total_entries
    expose :next_page_cursor, as: :next_cursor

    expose :notifications_at_current_page, as: :notifications, with: NotificationEntity
  end
end