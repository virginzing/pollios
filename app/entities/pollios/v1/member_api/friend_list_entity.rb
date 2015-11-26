module Pollios::V1::MemberAPI
  class FriendListEntity < Pollios::V1::BaseEntity

    expose_members :friends
    expose_members :followers
    expose_members :followings
    expose_members :blocks

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(current_member).social_linkage_ids
    end

    def blocks
      return object.blocks if object.member.id == current_member.id
      []
    end

    def current_member
      options[:current_member]
    end

  end
end