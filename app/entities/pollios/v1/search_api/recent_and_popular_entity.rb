module Pollios::V1::SearchAPI
  class RecentAndPopularEntity < Pollios::V1::BaseEntity

    expose :recent
    expose :popular, with: TagEntity

  end
end