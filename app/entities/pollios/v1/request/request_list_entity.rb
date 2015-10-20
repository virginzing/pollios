module Pollios::V1::Request
  class RequestListEntity < Pollios::V1::BaseEntity
    expose :group_requests, with: GroupRequestListEntity
    expose :friend_requests, with: FriendRequestListEntity
    expose :recommendations, with: RecommendationListEntity
  end
end