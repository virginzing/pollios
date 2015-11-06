module Pollios::V2::CurrentMemberAPI
  class MemberRewardEntity < Pollios::V2::BaseEntity

    expose :reward, with: Pollios::V2::Shared::RewardEntity

    expose :poll, if: -> (obj, opts) { obj.poll.present? } do |obj|
      Pollios::V1::PollAPI::PollDetailEntity.represent obj.poll, only: [:poll_id, :title]
    end

    expose :redeem_info do
      expose :id, as: :reward_id
      expose :reward_status
      expose :serial_code 
      expose :redeem, as: :claimed

      with_options(format_with: :as_integer) do
        expose :redeem_at, as: :claimed_at
      end

      expose :ref_no
    end

  end
end