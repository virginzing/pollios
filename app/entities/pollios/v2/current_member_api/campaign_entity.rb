module Pollios::V2::CurrentMemberAPI
	class CampaignEntity < Pollios::V2::BaseEntity

		expose :id, as: :campaign_id

		expose :name 
		expose :description 
		expose :get_photo_campaign, as: :photo_campaign, if: -> (obj, opts) { obj.get_photo_campaign.present? }
		expose :get_original_photo_campaign, as: :original_photo_campaign, if: -> (obj, opts) { obj.get_original_photo_campaign.present? }
    expose :type_campaign, as: :type

    with_options(format_with: :as_integer) do
      expose :announce_on
      expose :expire
    end

    expose :owner

    expose :rewards do |obj, opts|
      Pollios::V2::Shared::RewardEntity.represent obj.rewards, only: [:reward_id, :title, :detail, :total]
    end
    
	private

		def owner
      entity = Pollios::V1::PollAPI::MemberInPollEntity
			object.member.present? ? entity.represent(object.member) : entity.default_pollios_member
    end
    
  end
end