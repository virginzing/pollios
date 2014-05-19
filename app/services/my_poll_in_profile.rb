class MyPollInProfile
  include GroupApi

  def initialize(member, options)
    @member = member
    @options = options
  end

  def my_poll
    @my_poll ||= poll_created
  end

  def my_vote
    @my_vote ||= poll_voted
  end

  private

  def poll_created
    @member.polls.includes(:member, :campaign, :choices)
  end

  def poll_voted
    Poll.joins(:history_votes).includes(:member, :campaign).where("history_votes.member_id = ? AND history_votes.poll_series_id = 0", @member.id)
        .order("history_votes.created_at DESC")
  end
  
end