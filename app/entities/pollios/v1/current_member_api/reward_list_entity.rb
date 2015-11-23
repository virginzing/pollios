module Pollios::V1::CurrentMemberAPI
  class RewardListEntity < Pollios::V1::BaseEntity
    expose :rewards_at_current_page, as: :rewards, with: MemberRewardEntity
    expose :next_page_index
  end
end