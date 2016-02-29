module Pollios::V2::CurrentMemberAPI
  class RewardListEntity < Pollios::V2::BaseEntity
    expose :rewards_at_current_page, as: :rewards, with: MemberRewardEntity
    expose :next_index
  end
end