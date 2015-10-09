module Pollios::V1::Member
    class FriendSerializer < ActiveModel::Serializer
      has_many :friends, :followers, :followings, each_serializer: Pollios::V1::Shared::MemberForListSerializer

      def friends
        object.friends
      end

      def followers
        object.follower
      end

      def followings
        object.following
      end
    end
end
