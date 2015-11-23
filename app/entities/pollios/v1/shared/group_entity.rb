module Pollios::V1::Shared
  class GroupEntity < Pollios::V1::BaseEntity

    expose :id, as: :group_id

    expose :member_count do |obj|
      Group::ListMember.new(obj).active.count
    end

    expose :name
    expose :description, if: -> (obj, _) { obj.description.present? }
    expose :get_cover_group, as: :cover, if: -> (obj, _) { obj.get_cover_group.present? }
    expose :cover_preset, unless: -> (obj, _) { obj.get_cover_group.present? }
    expose :type, if: -> (obj, _) { obj.company? } do |obj|
      obj.group_type.downcase
    end

  end
end