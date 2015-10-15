module Pollios::V1::Member
	class RewardListEntity < Grape::Entity
		expose :rewards, with: Pollios::V1::Shared::RewardForListEntity
	end
end