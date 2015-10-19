module Pollios::V1::Member
	class RewardListEntity < Pollios::V1::BaseEntity
		expose :rewards, with: RewardForListEntity
	end
end