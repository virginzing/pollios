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
    @group_poll_ids ||= @my_group.pluck(:id)  
  end

  def group_by_name
    Hash[@friend_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def get_poll_friend
    @poll_of_friend ||= poll_of_friend  
  end

  private

  def poll_of_friend
    query = Poll.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign).
                 where("poll_members.member_id = ? AND poll_members.in_group = ?", friend_id, false)
  end
  
end
