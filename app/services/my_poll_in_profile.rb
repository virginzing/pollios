class MyPollInProfile
  include GroupApi

  def initialize(member, options = nil)
    @member = member
    @options = options
    @my_group = Member.list_group_active
  end

  def my_group_id
    @my_group_ids ||= @my_group.map(&:id)
  end

  def member_id
    @member.id
  end

  def list_my_friend_ids
    Member.list_friend_active.map(&:id) << @member.id
  end

  def my_vote_poll_ids
    @poll_voted_ids ||= @member.cached_my_voted.select{|e| e["poll_series_id"] == 0 }.collect{|e| e["poll_id"] }
  end

  def my_poll
    @my_poll ||= poll_created
  end

  def my_vote
    @my_vote ||= poll_voted
  end

  def my_watched
    @my_watched ||= poll_watched
  end

  ## create ##

  def create_public_poll
    my_poll.select{|p| p.public == true }.count
  end

  def create_friend_following_poll
    my_poll.select{|p| p.public == false && p.in_group == false }.count
  end

  def create_group_poll
    my_poll.select{|p| p.in_group == true }.count
  end

  ## vote ##

  def vote_public_poll
    my_vote.select{|p| p.public == true }.count
  end

  def vote_friend_following_poll
    my_vote.select{|p| p.public == false && p.in_group == false }.count
  end

  def vote_group_poll
    my_vote.select{|p| p.in_group == true }.count
  end

  ## watched ##

  def watch_public_poll
    my_watched.select{|p| p.public == true }.count
  end

  def watch_friend_following_poll
    my_watched.select{|p| p.public == false && p.in_group == false }.count
  end

  def watch_group_poll
    my_watched.select{|p| p.in_group == true }.count
  end

  private

  def poll_created
    query_poll_member = "polls.member_id = #{member_id} AND polls.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "polls.member_id = #{member_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "polls.public = 't' AND polls.member_id = #{member_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                       "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                       "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})",
                       my_group_id, my_group_id).references(:poll_groups)
  end

  def poll_voted
    query = Poll.available.joins(:history_votes => :choice).includes(:member, :poll_series, :campaign, :poll_groups)
                .select("polls.*, history_votes.choice_id as choice_id")
                .where("(history_votes.member_id = #{member_id} AND polls.in_group = 'f') " \
                       "OR (history_votes.member_id = #{member_id} AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)" \
                       "OR (history_votes.member_id = #{member_id} AND poll_groups.group_id IN (?))",
                       my_group_id).references(:poll_groups)
  end

  def poll_watched
    query = Poll.available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(watcheds.member_id = #{member_id} AND watcheds.poll_notify = 't')")
                .where("(watcheds.member_id = #{member_id} AND polls.in_group = 'f')" \
                       "OR (watcheds.member_id = #{member_id} AND polls.public = 't') " \
                       "OR (watcheds.member_id = #{member_id} AND poll_groups.group_id IN (?))", my_group_id)
                .order("watcheds.created_at DESC")
                .references(:poll_groups)
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

end
