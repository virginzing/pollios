module Pollios::V1::CurrentMember
  class RecommendationListEntity < Pollios::V1::BaseEntity
    expose :recommendations, as: :officials
    # expose :groups
    # expose :members
    # expose :facebook

  end
end