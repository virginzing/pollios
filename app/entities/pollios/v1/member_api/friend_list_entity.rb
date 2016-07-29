module Pollios::V1::MemberAPI
  class FriendListEntity < Pollios::V1::BaseEntity

    expose_members :friends
    expose_members :followers
    expose_members :followings
    expose_members :blocks

    def followers
      return [] if citizen_member?

      object.followers
    end

    def blocks
      return object.blocks if viewing_own_friends?

      []
    end

    private

    def current_member_linkage
      options[:current_member_linkage]
    end

    def current_member
      options[:current_member]
    end

    def viewing_own_friends?
      object.member.id == current_member.id
    end

    def citizen_member?
      object.member.citizen?
    end
  end
end