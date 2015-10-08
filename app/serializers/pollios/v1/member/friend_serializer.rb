module Pollios::V1::Member
    class FriendSerializer < ActiveModel::Serializer
      attributes :friends, :followers, :followings

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
