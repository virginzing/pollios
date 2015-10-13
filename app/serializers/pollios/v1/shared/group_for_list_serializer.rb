module Pollios::V1::Shared
  class GroupForListSerializer < ActiveModel::Serializer

    include Pollios::V1::Shared::APIHelpers

    delegate :current_member, to: :scope

    attributes :id, :group_id, :member_count, :name, :description
    attributes :cover, :cover_preset

    def initialize(object, options = {})
      super(object, options)
      @member_list = Group::ListMember.new(object)
    end

    def group_id
      object.id
    end

    def member_count
      @member_list.active.count
    end

    def cover
      object.get_cover_group
    end

  end
end