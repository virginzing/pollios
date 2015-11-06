module Pollios::V2::CurrentMemberAPI
  class MemberRewardEntity < Pollios::V2::BaseEntity

    expose :redeemable_info do
      expose :id, as: :redeem_id, if: -> (obj, opts) { obj.received? }
      expose :reward_status, as: :status
      expose :serial_code, if: -> (obj, opts) { obj.received? }
      expose :redeem, as: :claimed, if: -> (obj, opts) { obj.received? }

      with_options(format_with: :as_integer) do
        expose :redeem_at, as: :claimed_at, if: -> (obj, opts) { obj.received? }
      end

      expose :ref_no, if: -> (obj, opts) { obj.received? }
    end

    expose :reward, with: Pollios::V2::Shared::RewardEntity

    expose :poll, if: -> (obj, opts) { obj.poll.present? } do |obj|
      Pollios::V1::PollAPI::PollDetailEntity.represent obj.poll, only: [:poll_id, :title]
    end

  end
end