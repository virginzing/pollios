module Pollios::V1::Member
    class FriendListSerializer < ActiveModel::Serializer

      include Pollios::V1::Shared::APIHelpers
      
      has_many :friends, :followers, :followings, :blocks, each_serializer: Pollios::V1::Shared::MemberForListSerializer

    end
end
