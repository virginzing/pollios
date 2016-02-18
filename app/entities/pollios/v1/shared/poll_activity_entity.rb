module Pollios::V1::Shared
  class PollActivityEntity < PollForListEntity

    unexpose :member_states
    unexpose :vote_all
    unexpose :expire_date
    unexpose :created_at
    unexpose :type_poll
    unexpose :poll_within
    unexpose :allow_comment
    unexpose :comment_count
    unexpose :get_require_info
    unexpose :get_creator_must_vote
    unexpose :show_result
    unexpose :close_status
    unexpose :campaign
    unexpose :member_reward

    expose :action
    with_options(format_with: :as_integer) do
      expose :activity_at
    end

  end
end