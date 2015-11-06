module Pollios::V2::Shared
  class RewardEntity < Pollios::V2::BaseEntity
    expose :title
    expose :detail
    expose :redeem_instruction
    expose :self_redeem

    with_options(format_with: :as_integer) do
      expose :expire_at
    end

    expose :campaign, with: Pollios::V2::CurrentMemberAPI::CampaignEntity
  end

end