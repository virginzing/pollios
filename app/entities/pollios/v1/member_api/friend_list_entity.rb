module Pollios::V1::MemberAPI
  class FriendListEntity < Pollios::V1::BaseEntity

    expose_members :friends
    expose_members :followers
    expose_members :followings
    expose_members :blocks

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(options[:current_member]).social_linkage_ids
    end
  end
end