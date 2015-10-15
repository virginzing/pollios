module Pollios::V1::Shared
  class RewardForListEntity < Grape::Entity

    expose :campaign_detail
    expose :reward_info

    def campaign_detail
      {
        id: object.campaign.id,
        name: object.campaign.name.presence || "",
        description: object.campaign.description.presence || "",
        how_to_redeem: object.campaign.how_to_redeem.presence || "",
        expire: object.campaign.expire.to_i,
        photo_campaign: object.campaign.get_photo_campaign,
        original_photo_campaign: object.campaign.get_original_photo_campaign,
        used: object.campaign.used,
        limit: object.campaign.limit,
        owner_info: object.campaign.member.present? ? MemberInfoFeedSerializer.new(object.campaign.member) : System::DefaultMember.new.to_json,
        created_at: object.campaign.created_at.to_i,
        type_campaign: object.campaign.type_campaign,
        announce_on: object.campaign.announce_on.to_i,
        random_reward: object.campaign.begin_sample == object.campaign.end_sample ? false : true
      }
    end

    def reward_info
      {
        id: object.id,
        reward_status: object.reward_status,
        serial_code: object.serial_code || "",
        redeem: object.redeem,
        redeem_at: object.redeem_at.to_i.presence || "",
        ref_no: object.ref_no || "",
        created_at: object.created_at.to_i,
        title: object.campaign.get_reward_title,
        detail: object.campaign.get_reward_detail,
        expire: object.campaign.get_reward_expire,
        redeem_myself: object.campaign.redeem_myself
      }
    end

  end
end