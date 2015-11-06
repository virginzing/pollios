module Pollios::V1::Shared
  class RewardEntity < Pollios::V1::BaseEntity
    expose :campaign_id
    expose :name

    def name
      object.campaign.name
    end
  end

end