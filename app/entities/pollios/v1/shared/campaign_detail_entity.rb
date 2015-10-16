module Pollios::V1::Shared
	class CampaignDetailEntity < Grape::Entity

		expose :id, as: :campaign_id
		expose :name do |object|
			object.name.to_s
		end
		expose :description do |object|
			object.description.to_s
		end
		expose :how_to_redeem do |object|
			object.how_to_redeem.to_s
		end
		expose :expire do |object|
			object.expire.to_i
		end

		expose :get_photo_campaign, as: :photo_campaign

		expose :get_original_photo_campaign,as: :original_photo_campaign
		expose :used
		expose :limit
		expose :member, as: :owner_info
	
		# expose :owner_info do |object|
		# 	object.member.present? ? MemberInfoFeedSerializer.new(object.member) : System::DefaultMember.new.to_json
		# end
		expose :created_at do |object|
			object.created_at.to_i
		end
		expose :type_campaign
		expose :announce_on do |object|
			object.announce_on.to_i
		end
		expose :random_reward do |object|
			object.begin_sample == object.end_sample ? false : true
		end

	end
end