module Pollios::V1::Shared
  class GroupForListEntity < Grape::Entity

    expose :id
    expose :group_id
    expose :member_count
    expose :name
    expose :description, if: Proc.new { object.description.present? }
    expose :get_cover_group, as: :cover, if: Proc.new {object.get_cover_group.present? }
    expose :cover_preset, unless: Proc.new {object.get_cover_group.present? }

    def member_count
      Group::ListMember.new(object).active.count
    end

    def group_id
      object.id
    end

  end
end
