module Pollios::V1::Member
	class CampaignDetailEntity < Pollios::V1::BaseEntity

		expose :id, as: :campaign_id

		expose :name 
		expose :description 
		expose :how_to_redeem 

		expose :get_photo_campaign, as: :photo_campaign

		expose :get_original_photo_campaign, as: :original_photo_campaign
		expose :used
		expose :limit

		expose :owner_info
    expose :type_campaign

    with_options(format_with: :as_integer) do
      expose :created_at
      expose :announce_on
      expose :expire
    end

		expose :random_reward do |object|
			object.begin_sample == object.end_sample ? false : true
		end

		private

		def owner_info
			object.member.present? ? CampaignOwnerDetailEntity.represent(object.member) : CampaignOwnerDetailEntity.default_pollios_member
    end
    
  end
end