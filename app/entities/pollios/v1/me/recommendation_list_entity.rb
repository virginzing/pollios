module Pollios::V1::Me
  class RecommendationListEntity < Pollios::V1::BaseEntity
    expose :officials
    expose :groups
    expose :members
    expose :facebook

    def officials
      ["official1", "officials2"]
    end

    def groups
      ["groups", "groups"]
    end

    def members
      ["member", "member"]
    end

    def facebook
      ["facebook", "facebook"]
    end

  end
end