class FriendPollInProfile

  def initialize(member, friend, options)
    @member = member
    @friend = friend
    @options = options
    @friend_group = @friend.cached_get_group_active
    @my_group = @member.cached_get_group_active
  end
  
  def friend_id
    @friend.id
  end

  def my_group_id
    @my_group_ids ||= @my_group.map(&:id)  
  end

  def friend_group_id
    @friend_group_ids ||= @friend_group.map(&:id)
  end

  def my_and_friend_group
    my_group_id & friend_group_id
  end

  def list_my_friend_ids
    @member.cached_get_friend_active.map(&:id) << @member.id
  end

  def is_friend
    list_my_friend_ids.include?(friend_id) ? friend_id : nil
  end

  def group_by_name
    Hash[@friend_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def get_poll_friend
    @poll_created ||= poll_created 
  end

  def get_vote_friend
    @poll_voted ||= poll_voted
  end

  def poll_friend_count
    get_poll_friend.count
  end

  def vote_friend_count
    get_vote_friend.count
  end

  private

  def poll_created
    query_poll_member = "poll_members.member_id = #{is_friend} AND poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "poll_members.member_id = #{is_friend} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "poll_members.public = 't' AND poll_members.member_id = #{is_friend}"

    query = Poll.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups).
                where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})", 
                my_and_friend_group, my_and_friend_group).references(:poll_groups)
  end

  def poll_voted
    query = Poll.joins(:history_votes).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(history_votes.member_id = ? AND polls.member_id IN (?) AND polls.in_group_ids = ?) " \
                "OR (history_votes.member_id = ? AND polls.public = ?) " \
                "OR (history_votes.member_id = ? AND poll_groups.group_id IN (?))", 
                friend_id, list_my_friend_ids, "0",
                friend_id, true,
                friend_id, my_and_friend_group).references(:poll_groups)
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  
end

