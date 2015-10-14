module Pollios::V1::Member
  class RewardListSerializer < Pollios::V1::BaseSerializer

    has_many :list_reward, each_serializer: Pollios::V1::Shared::RewardForListSerializer

  end
end