class PollFriendTimeline
  def initialize(member, friend, params)
    @friend = friend
    @member = member
    @params = params
    @friend_group = friend.get_group_active
    @my_group = member.get_group_active
  end

  def friend_id
    @friend.id
  end

  def my_group_id
    @my_group_ids ||= @my_group.pluck(:id)
  end

  def friend_group_id
    @friend_group_ids ||= @friend_group.pluck(:id)
  end

  def my_and_friend_group
    my_group_id & friend_group_id
  end

  def group_by_name
    Hash[@friend_group.map{ |group| [group.id, GroupDetailSerializer.new(group).as_json] }]
  end

  def get_poll_friend
    @poll_of_friend ||= poll_of_friend
  end

  private

  def poll_of_friend
    query = Poll.available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups).
                where("(poll_members.member_id = ? AND poll_members.in_group = ?) " \
                "OR (poll_members.member_id = ? AND poll_groups.group_id IN (?) " \
                "OR (poll_members.public = ? AND poll_members.member_id = ?))",
                friend_id, false,
                friend_id, my_and_friend_group,
                true, friend_id).references(:poll_groups)
  end

end
