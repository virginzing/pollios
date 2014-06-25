class MyPollInProfile
  include GroupApi

  def initialize(member, options)
    @member = member
    @options = options
  end

  def member_id
    @member.id
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

  private

  def poll_created
    # @member.polls.includes(:member, :campaign, :choices)
    Poll.available.joins(:poll_members).includes(:member, :campaign, :choices).where("poll_members.member_id = #{member_id} AND poll_members.share_poll_of_id = 0")
  end

  def poll_voted
    Poll.available.joins(:history_votes).includes(:member, :campaign).where("history_votes.member_id = ? AND history_votes.poll_series_id = 0", member_id)
        .order("history_votes.created_at DESC")
  end

  def poll_watched
    Poll.available.joins(:watcheds).includes(:member, :campaign).where("watcheds.member_id = #{member_id}").order("watcheds.created_at DESC")
  end
  
end