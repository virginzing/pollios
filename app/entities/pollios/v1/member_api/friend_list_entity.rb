module Pollios::V1::MemberAPI
  class FriendListEntity < Pollios::V1::BaseEntity

    expose_members :friends
    expose_members :followers, unless: -> (_, _) { current_member.citizen? }
    expose_members :followings
    expose_members :blocks

    private

    def current_member_linkage
      options[:current_member_linkage]
    end

    def blocks
      return object.blocks if viewing_own_friends?
      []
    end

    def current_member
      options[:current_member]
    end

    def viewing_own_friends?
      object.member.id == current_member.id
    end
  end
end