module InitializableFeed

  def initialize_poll_feed
    return unless @current_member.present?
    init_list_friend = Member::ListFriend.new(Member.current_member)
    init_list_poll = Member::ListPoll.new(Member.current_member)
    init_list_group = Member::ListGroup.new(Member.current_member)

    Member.list_friend_active = init_list_friend.active
    Member.list_friend_block = init_list_friend.block
    Member.list_friend_request = init_list_friend.friend_request
    Member.list_your_request = init_list_friend.your_request
    Member.list_friend_following = init_list_friend.following

    Member.list_group_active = init_list_group.active
    Member.reported_polls = init_list_poll.reports
    Member.viewed_polls   = init_list_poll.history_viewed
    Member.voted_polls    = init_list_poll.voted_all
    Member.watched_polls  = init_list_poll.watched_poll_ids
  end
end
