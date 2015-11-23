module Pollios::V1::CurrentMemberAPI
  class MemberRewardEntity < Pollios::V1::BaseEntity

    expose :reward_info do
      expose :id, as: :reward_id
      expose :reward_status
      expose :serial_code 
      expose :redeem

      with_options(format_with: :as_integer) do
        expose :redeem_at
        expose :created_at
      end

      expose :ref_no
    end

    expose :campaign, with: CampaignDetailEntity, as: :campaign_detail
    expose :poll, with: CampaignPollDetailEntity, if: -> (object, _) { object.poll.present? }

  end
end