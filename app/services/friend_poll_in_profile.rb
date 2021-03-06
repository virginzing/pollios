class FriendPollInProfile

  def initialize(member, friend, options)
    @member = member
    @friend = friend
    @options = options
    @my_group = Member.list_group_active
  end
  
  def friend_group
    init_list_group ||= Member::GroupList.new(@friend)
    init_list_group.active  
  end

  def friend_id
    @friend.id
  end

  def my_group_id
    @my_group_ids ||= @my_group.map(&:id)  
  end

  def friend_group_id
    @friend_group_ids ||= friend_group.map(&:id)
  end

  def my_and_friend_group
    my_group_id & friend_group_id
  end

  def list_my_friend_ids
    Member.list_friend_active.map(&:id) << @member.id
  end

  def groups
    @groups ||= @member.id == friend_id ? my_group : mutual_or_public_group
  end

  def together_group
    @together_group ||= mutual_or_public_group
  end

  def hash_as_admin
    
  end

  def is_friend
    list_my_friend_ids.include?(friend_id) ? friend_id : 0
  end

  def group_by_name
    Hash[friend_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group]] }]
  end

  def get_poll_friend
    @poll_created ||= poll_created 
  end

  def get_vote_friend
    @poll_voted ||= poll_voted
  end

  def get_watched_friend
    @poll_watched ||= poll_watched
  end

  def get_poll_friend_with_visibility
    @poll_created_visibility ||= poll_created_with_visibility
  end

  def get_vote_friend_with_visibility
    @poll_voted_visibility ||= poll_voted_with_visibility
  end

  def get_watched_friend_with_visibility
    @poll_watched_visibility ||= poll_watched_with_visibility
  end

  def poll_friend_count
    poll_created_with_visibility.size
  end

  def vote_friend_count
    poll_voted_with_visibility.size
  end

  def watched_friend_count
    poll_watched_with_visibility.size
  end

  def group_friend_count
    mutual_or_public_group.map(&:id).uniq.size
  end

  def block_friend_count
    block_friend.size
  end

  private

  def poll_created
    query_poll_member = "poll_members.member_id = #{friend_id} AND poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "poll_members.member_id = #{friend_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "poll_members.public = 't' AND poll_members.member_id = #{friend_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups).
                where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})", 
                my_and_friend_group, my_and_friend_group).references(:poll_groups)
  end

  def poll_voted
    query = Poll.available.joins(:history_votes).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(history_votes.member_id = #{friend_id} AND polls.member_id IN (?) AND polls.in_group = 'f') " \
                "OR (history_votes.member_id = #{friend_id} AND polls.public = 't') " \
                "OR (history_votes.member_id = #{friend_id} AND poll_groups.group_id IN (?))", 
                (list_my_friend_ids << friend_id),
                my_and_friend_group).references(:poll_groups)
  end

  def poll_watched
    query = Poll.available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(watcheds.member_id = #{friend_id} AND polls.member_id IN (?) AND polls.in_group_ids = '0')" \
                "OR (watcheds.member_id = #{friend_id} AND polls.public = 't') " \
                "OR (watcheds.member_id = #{friend_id} AND poll_groups.group_id IN (?))", (list_my_friend_ids << friend_id), my_and_friend_group).references(:poll_groups)
  end

  def poll_created_with_visibility
    query_poll_member = "polls.member_id = #{is_friend} AND polls.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "polls.member_id = #{friend_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "polls.public = 't' AND polls.member_id = #{friend_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})", 
                my_and_friend_group, my_and_friend_group).references(:poll_groups)
  end

  def poll_voted_with_visibility
    query = Poll.available.joins(:history_votes).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
            .where("(history_votes.member_id = #{is_friend} AND polls.in_group = 'f') " \
            "OR (history_votes.member_id = #{friend_id} AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)" \
            "OR (history_votes.member_id = #{friend_id} AND poll_groups.group_id IN (?))",
            my_and_friend_group).references(:poll_groups)
  end

  def poll_watched_with_visibility
    query = Poll.available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
            .where("(watcheds.member_id = #{friend_id} AND watcheds.poll_notify = 't')")
            .where("(watcheds.member_id = #{friend_id} AND polls.in_group = 'f')" \
            "OR (watcheds.member_id = #{friend_id} AND polls.public = 't') " \
            "OR (watcheds.member_id = #{friend_id} AND poll_groups.group_id IN (?))", my_and_friend_group)
            .order("watcheds.created_at DESC")
            .references(:poll_groups)
  end

  def block_friend
    query = @friend.get_friend_blocked
  end

  def mutual_or_public_group
    query = Group.joins(:group_members_active).where("(groups.id IN (?)) OR (group_members.active = 't' AND groups.public = 't' AND group_members.member_id = #{friend_id})", my_and_friend_group)
                .select("groups.*, count(group_members) as all_member_count")
                .group("groups.id")
                .order("groups.name asc")
    query
  end

  def my_group
    query = Group.joins(:group_members_active).where("groups.id IN (?)", my_group_id)
                .includes(:polls_active)
                .select("groups.*, count(group_members.group_id) as member_in_group")
                .group("groups.id, polls.id, members.id").order("groups.name asc")
                .references(:polls_active)
    query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  
end

