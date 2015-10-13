module Pollios::V1::Shared
	class RewardForListSerializer < Pollios::V1::BaseSerializer

		attributes :campiagn_detail, :reward_info

		def initialize(object, options = {})
			super(object, options )
			@reward_list = Member::RewardList.new(object)
		end

		def campiagn_detail
			object.campaign
		end

		def reward_info
			object
		end

	end
end