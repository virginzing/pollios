class Poll::ListMentionable

  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def poll_id
    @poll.id
  end

  def init_list_friend
    @init_list_friend ||= Member::MemberList.new(@member)
  end

  def get_list_mentionable
    if @poll.in_group
      summary_member_can_mentionable_in_group
    else
      summary_member_can_mentionable_in_friend_public
    end
  end


  private

  def people_see_poll_in_groups_member_ids
    member_ids = []

    @poll.groups.each do |group|
      member_ids << Group::MemberList.new(group).active.map(&:id)
    end

    member_ids.uniq
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

  def summary_member_can_mentionable_in_group
    Member.unscoped.where(id: people_see_poll_in_groups_member_ids)
  end

  def summary_member_can_mentionable_in_friend_public
    merge_member_ids = friend_active_member_ids | people_voted_this_poll_member_ids | people_commented_this_poll_member_ids
    Member.unscoped.where(id: merge_member_ids)
  end


end