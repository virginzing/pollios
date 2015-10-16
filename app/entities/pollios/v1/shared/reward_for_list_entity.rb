module Pollios::V1::Shared
  class RewardForListEntity < Grape::Entity

    expose :id, as: :reward_id
    expose :reward_status
    expose :serial_code do |object|
      object.serial_code.to_s
    end
    expose :redeem
    expose :redeem_at do |object|
      object.redeem_at.to_i
    end
    expose :ref_no
    expose :created_at do |object| 
      object.created_at.to_i
    end
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

    expose :campaign, using: Pollios::V1::Shared::CampaignDetailEntity
    expose :poll, using: Pollios::V1::Shared::CampaignPollDetailEntity

  end
end