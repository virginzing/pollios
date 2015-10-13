module Pollios::V1::Shared
  class GroupForListSerializer < Pollios::V1::BaseSerializer

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