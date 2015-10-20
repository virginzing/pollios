module Pollios::V1::Me
  class RewardForListEntity < Pollios::V1::BaseEntity

    expose :id, as: :reward_id
    expose :reward_status
    expose :serial_code 
    expose :redeem

    with_options(format_with: :as_integer) do
      expose :redeem_at
      expose :created_at
    end

    expose :ref_no

    expose :title do |object|
      object.campaign.get_reward_title
    end
    expose :detail do |object|
      object.campaign.get_reward_detail
    end
    expose :expire do |object|
      object.campaign.get_reward_expire
    end
    expose :redeem_myself do |object|
      object.campaign.redeem_myself
    end

    expose :campaign, with: CampaignDetailEntity
    expose :poll, with: CampaignPollDetailEntity

  end
end