module Pollios::V1::Me
	class RewardListEntity < Pollios::V1::BaseEntity
		expose :rewards_at_current_page, as: :rewards, with: RewardForListEntity
		expose :next_page_index
	end
end