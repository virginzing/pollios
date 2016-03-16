module Pollios::V1::CurrentMemberAPI
  class GroupForNotificationEntity < Pollios::V1::BaseEntity

    expose :id, as: :group_id
    expose :name
    expose :get_cover_group, as: :cover, if: -> (obj, _) { obj.get_cover_group.present? }
    expose :cover_preset, unless: -> (obj, _) { obj.get_cover_group.present? }

  end
end