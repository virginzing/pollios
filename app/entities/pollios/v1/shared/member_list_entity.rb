module Pollios::V1::Shared
  class MemberListEntity < Pollios::V1::BaseEntity

    expose :next_index
    expose_members :members

    def members
      object.members_by_page(object.send(type))
    end

    def type
      options[:member]
    end

    def next_index
      object.next_index(members)
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end

  end
end