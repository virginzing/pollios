module Pollios::V2::CurrentMemberAPI
  class MemberRewardEntity < Pollios::V2::BaseEntity

    expose :reward_status, as: :status

    # if user got reward, show redeemable info, along with rewarad
    expose :redeemable_info, if: -> (obj, opts) { obj.received? } do
      expose :id, as: :redeem_id
      expose :reward_status, as: :status
      expose :serial_code
      expose :redeem, as: :claimed

      with_options(format_with: :as_integer) do
        expose :redeem_at, as: :claimed_at
      end

      expose :ref_no, if: -> (obj, opts) { obj.received? }

    end

    expose :reward, with: Pollios::V2::Shared::RewardEntity, if: -> (obj, opts) { obj.received? }

    # if user not getting reward or still waiting annoucement, showing campaign info
    expose :campaign, if: -> (obj, opts) { !obj.received? } do
    end

    # always show poll if poll information present
    expose :poll, if: -> (obj, opts) { obj.poll.present? } do |obj|
      Pollios::V1::PollAPI::PollDetailEntity.represent obj.poll, only: [:poll_id, :title]
    end

  end
end