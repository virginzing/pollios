module Pollios::V1::Member
    class FriendSerializer < ActiveModel::Serializer
      attributes :id, :fullname
    end
end
