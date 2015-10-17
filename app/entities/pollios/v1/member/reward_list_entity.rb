module Pollios::V1::Member
	class RewardListEntity < Grape::Entity
		expose :rewards, with: RewardForListEntity
	end
end