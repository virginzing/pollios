module Pollios::V2::Shared
  class RewardEntity < Pollios::V2::BaseEntity
    expose :id, as: :reward_id
    expose :title
    expose :detail
    expose :redeem_instruction
    expose :self_redeem

    with_options(format_with: :as_integer) do
      expose :expire_at, if: -> (obj, opts) { obj.can_expire? }
    end

    expose :no_expiration

    expose :campaign do |obj|
      Pollios::V2::CurrentMemberAPI::CampaignEntity.represent obj.campaign, except: [:expire]
    end
  end

end