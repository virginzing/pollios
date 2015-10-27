module Pollios::V1::Shared
  class GroupEntity < Pollios::V1::BaseEntity

    expose :id, as: :group_id

    expose :member_count do |object|
      Group::ListMember.new(object).active.count
    end

    expose :name
    expose :description, if: -> (object, options) { object.description.present? }
    expose :get_cover_group, as: :cover, if: -> (object, options) { object.get_cover_group.present? }
    expose :cover_preset, unless: -> (object, options) { object.get_cover_group.present? }
    expose :type, if: -> (object, options) { object.company? } do |object|
      object.group_type.downcase
    end

  end
end