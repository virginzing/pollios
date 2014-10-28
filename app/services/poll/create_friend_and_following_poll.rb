class Poll::CreateFriendAndFollowingPoll < Poll::CreatePoll

  def initialize(params)
    @params = params
  end

  def friend_following_params
    hash = {
      in_group_ids: "0",
      require_info: false
    }

    @params.merge(hash)
  end

  def add_poll_friend_following_to_timeline
    PollMember.create!(poll_id: poll.id, member_id: poll.member_id, share_poll_of_id: 0, public: set_public_poll, series: false, expire_date: set_expire_date)
  end

end