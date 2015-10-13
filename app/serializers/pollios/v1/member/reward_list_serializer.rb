module Pollios::V1::Member
  class RewardListSerializer < Pollios::V1::BaseSerializer

    attributes :member

    def member
      object.member
    end
  end
end