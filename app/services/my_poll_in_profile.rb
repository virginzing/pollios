class MyPollInProfile
  include GroupApi

  def initialize(member, options)
    @member = member
    @options = options
  end

  def member_id
    @member.id
  end

  def my_vote_poll_ids
    @poll_voted_ids ||= @member.cached_my_voted.select{|e| e[3] == 0 }.collect{|e| e.first }
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
    my_poll.select{|p| p.public == false && p.in_group_ids == "0" }.count
  end

  def create_group_poll
    my_poll.select{|p| p.public == false && p.in_group_ids != "0" }.count
  end

  ## vote ##

  def vote_public_poll
    poll_voted.select{|p| p.public == true }.count
  end

  def vote_friend_following_poll
    poll_voted.select{|p| p.public == false && p.in_group_ids == "0" }.count
  end

  def vote_group_poll
    poll_voted.select{|p| p.public == false && p.in_group_ids != "0" }.count
  end

  ## watched ##

  def watch_public_poll
    poll_watched.select{|p| p.public == true }.count
  end

  def watch_friend_following_poll
    poll_watched.select{|p| p.public == false && p.in_group_ids == "0" }.count
  end

  def watch_group_poll
    poll_watched.select{|p| p.public == false && p.in_group_ids != "0" }.count
  end

  private

  def poll_created
    query = Poll.available.joins(:poll_members).includes(:member, :campaign, :choices)
        .where("polls.vote_all > 0")
        .where("(poll_members.member_id = #{member_id} AND poll_members.share_poll_of_id = 0) OR (polls.id IN (?) AND polls.member_id = #{member_id} AND poll_members.share_poll_of_id = 0)", my_vote_poll_ids)
    query
  end

  def poll_voted
    Poll.available.joins(:history_votes).includes(:member, :campaign).where("history_votes.member_id = ? AND history_votes.poll_series_id = 0", member_id)
        .order("history_votes.created_at DESC")
  end

  def poll_watched
    query = Poll.available.joins(:watcheds).includes(:member, :campaign)
                .where("(watcheds.member_id = #{member_id} AND watcheds.poll_notify = 't')")
                .order("watcheds.created_at DESC")
    query
  end
  
end