class FriendPollInProfile

  def initialize(member, friend, options)
    @member = member
    @friend = friend
    @options = options
    @friend_group = @friend.cached_get_group_active
    @my_group = Member.list_group_active
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
    Member.list_friend_active.map(&:id) << @member.id
  end

  def groups
    @groups ||= mutual_or_public_group
  end

  def is_friend
    list_my_friend_ids.include?(friend_id) ? friend_id : 0
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
    get_poll_friend.count
  end

  def vote_friend_count
    get_vote_friend.count
  end

  def watched_friend_count
    get_watched_friend.count
  end

  def group_friend_count
    groups.count.count
  end

  def block_friend_count
    block_friend.count
  end

  ## create ##

  def create_public_poll
    get_poll_friend.select{|p| p.public == true }.count
  end

  def create_friend_following_poll
    get_poll_friend.select{|p| p.public == false && p.in_group_ids == "0" }.count
  end

  def create_group_poll
    get_poll_friend.select{|p| p.public == false && p.in_group_ids != "0" }.count
  end

    ## vote ##

  def vote_public_poll
    get_vote_friend.select{|p| p.public == true }.count
  end

  def vote_friend_following_poll
    get_vote_friend.select{|p| p.public == false && p.in_group_ids == "0" }.count
  end

  def vote_group_poll
    get_vote_friend.select{|p| p.public == false && p.in_group_ids != "0" }.count
  end

  ## watched ##

  def watch_public_poll
    get_watched_friend.select{|p| p.public == true }.count
  end

  def watch_friend_following_poll
    get_watched_friend.select{|p| p.public == false && p.in_group_ids == "0" }.count
  end

  def watch_group_poll
    get_watched_friend.select{|p| p.public == false && p.in_group_ids != "0" }.count
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
                .where("(history_votes.member_id = #{friend_id} AND polls.member_id IN (?) AND polls.in_group_ids = '0') " \
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
    query_poll_member = "poll_members.member_id = #{is_friend} AND poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "poll_members.member_id = #{friend_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "poll_members.public = 't' AND poll_members.member_id = #{friend_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups).
                where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})", 
                my_and_friend_group, my_and_friend_group).references(:poll_groups)
  end

  def poll_voted_with_visibility
    query = Poll.available.joins(:history_votes).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
            .where("(history_votes.member_id = #{is_friend} AND polls.member_id IN (?) AND polls.in_group_ids = '0') " \
            "OR (history_votes.member_id = #{friend_id} AND polls.public = 't') " \
            "OR (history_votes.member_id = #{friend_id} AND poll_groups.group_id IN (?))", 
            list_my_friend_ids,
            my_and_friend_group).references(:poll_groups)
  end

  def poll_watched_with_visibility
    query = Poll.available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
            .where("(watcheds.member_id = #{friend_id} AND polls.member_id IN (?) AND polls.in_group_ids = '0')" \
            "OR (watcheds.member_id = #{friend_id} AND polls.public = 't') " \
            "OR (watcheds.member_id = #{friend_id} AND poll_groups.group_id IN (?))", list_my_friend_ids, my_and_friend_group).references(:poll_groups)
  end

  def block_friend
    query = @friend.get_friend_blocked
  end

  def mutual_or_public_group
    member_report_poll = Member.reported_polls.map(&:id)  ## poll ids
    member_block = Member.list_friend_block.map(&:id)  ## member ids

    query = Group.where("groups.id IN (?) OR groups.public = 't'", my_and_friend_group).
          joins(:group_members).includes(:polls_active).
          select("groups.*, count(group_members.group_id) as member_in_group").
          group("groups.id").
          order("groups.name asc").
          group("polls.id")

    query = query.where("polls.id NOT IN (?)", member_report_poll) if member_report_poll.count > 0
    query = query.where("polls.member_id NOT IN (?)", member_block) if member_block.count > 0
    query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  
end

