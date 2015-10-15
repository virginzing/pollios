module Pollios::V1::Shared
	class RewardForListSerializer < Pollios::V1::BaseSerializer

		attributes :campaign_detail, :reward_info

		def initialize(object, options = {})
			super(object, options )
			@reward_list = Member::RewardList.new(object)
			@campaign = object.campaign
		end

		def campaign_detail
			{
        id: @campaign.id,
        name: @campaign.name.presence || "",
        description: @campaign.description.presence || "",
        how_to_redeem: @campaign.how_to_redeem.presence || "",
        expire: @campaign.expire.to_i,
        photo_campaign: @campaign.get_photo_campaign,
        original_photo_campaign: @campaign.get_original_photo_campaign,
        used: @campaign.used,
        limit: @campaign.limit,
        owner_info: @campaign.member.present? ? MemberInfoFeedSerializer.new(@campaign.member) : System::DefaultMember.new.to_json,
        created_at: @campaign.created_at.to_i,
        type_campaign: @campaign.type_campaign,
        announce_on: @campaign.announce_on.to_i,
        random_reward: @campaign.begin_sample == @campaign.end_sample ? false : true
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
       title: @campaign.get_reward_title,
       detail: @campaign.get_reward_detail,
       expire: @campaign.get_reward_expire,
       redeem_myself: @campaign.redeem_myself
     }
   end

 end
end