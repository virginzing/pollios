class Poll::ListMentionable

  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def poll_id
    @poll.id
  end

  def init_list_friend
    @init_list_friend ||= Member::ListFriend.new(@member)
  end

  def get_list_mentionable
    summary_member_can_mentionable
  end


  private

  def people_see_poll_in_groups_member_ids
    []
  end

  def people_voted_this_poll_member_ids
    HistoryVote.unscoped.where(poll_id: poll_id).pluck(:member_id).uniq | []
  end

  def people_commented_this_poll_member_ids
    Comment.unscoped.where(poll_id: poll_id).pluck(:member_id).uniq | []
  end

  def friend_active_member_ids
    init_list_friend.active.map(&:id).uniq | []
  end

  def summary_member_can_mentionable
    merge_member_ids = friend_active_member_ids | people_see_poll_in_groups_member_ids | people_voted_this_poll_member_ids | people_commented_this_poll_member_ids
    Member.unscoped.where(id: merge_member_ids)
  end


end