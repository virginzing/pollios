module Pollios::V1::Member
  class RewardListEntity < Grape::Entity
	expose :list_reward, with: Pollios::V1::Shared::RewardForListEntity
  end
end