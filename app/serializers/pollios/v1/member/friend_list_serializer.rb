module Pollios::V1::Member
    class FriendListSerializer < ActiveModel::Serializer
      has_many :friends, :followers, :followings, each_serializer: Pollios::V1::Shared::MemberForListSerializer

    end
end
