module Pollios::V2::CurrentMemberAPI
	class CampaignEntity < Pollios::V2::BaseEntity

		expose :id, as: :campaign_id

		expose :name 
		expose :description 
		expose :get_photo_campaign, as: :photo_campaign, if: -> (obj, opts) { obj.get_photo_campaign.present? }
		expose :get_original_photo_campaign, as: :original_photo_campaign, if: -> (obj, opts) { obj.get_original_photo_campaign.present? }
		expose :owner
  #   expose :type_campaign

  #   with_options(format_with: :as_integer) do
  #     expose :created_at
  #     expose :announce_on
  #     expose :expire
  #   end

		# expose :random_reward do |object|
		# 	object.begin_sample == object.end_sample ? false : true
		# end

	private

		def owner
      entity = Pollios::V1::Shared::MemberEntity
			object.member.present? ? entity.represent(object.member) : entity.default_pollios_member
    end
    
  end
end