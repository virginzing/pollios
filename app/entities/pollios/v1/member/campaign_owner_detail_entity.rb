module Pollios::V1::Member
  class CampaignOwnerDetailEntity < Pollios::V1::Shared::MemberEntity

		expose :key_color do |object|
			object.key_color.to_s
		end

	end
end