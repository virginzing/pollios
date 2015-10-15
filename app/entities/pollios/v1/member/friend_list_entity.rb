module Pollios::V1::Member
  class FriendListEntity < Grape::Entity

    expose :friends do |object, options|
      Pollios::V1::Shared::MemberForListEntity.represent object.friends, current_member_linkage: current_member_linkage
    end

    expose :followers do |object, options|
      Pollios::V1::Shared::MemberForListEntity.represent object.followers, current_member_linkage: current_member_linkage
    end

    expose :followings do |object, options|
      Pollios::V1::Shared::MemberForListEntity.represent object.followings, current_member_linkage: current_member_linkage
    end

    expose :blocks do |object, options|
      Pollios::V1::Shared::MemberForListEntity.represent object.blocks, current_member_linkage: current_member_linkage
    end

    def current_member_linkage
      current_member = options[:current_member]
      Member::MemberList.new(current_member).social_linkage_ids
    end
  end
end