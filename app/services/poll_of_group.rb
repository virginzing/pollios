class PollOfGroup
  include GroupApi

  attr_accessor :poll_series, :poll_nonseries, :series_shared, :nonseries_shared

  def initialize(member, group, params = {})
    @member = member
    @group = group
    @params = params
    @poll_series = []
    @poll_nonseries = []
    @series_shared = []
    @nonseries_shared = []
  end

  def group_id
    @params["id"]
  end

  def get_poll_of_group
    @poll_of_group ||= poll_of_group
  end

  def get_poll_of_group_company
    @poll_of_group_company ||= poll_of_group_company
  end

  private

  def poll_of_group
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    @query = Poll.unscoped.order("updated_at DESC, created_at DESC").available.joins(:poll_groups).includes(:history_votes)
                .select("polls.*, poll_groups.share_poll_of_id as share_poll, poll_groups.group_id as group_of_id")
                .where("(#{poll_group_query} AND #{poll_unexpire}) OR (#{poll_group_query} AND #{poll_expire_have_vote})").uniq
    @query
  end

  def poll_of_group_company
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    @query = Poll.unscoped.order("created_at DESC").joins(:poll_groups).includes(:history_votes)
                .select("polls.*, poll_groups.share_poll_of_id as share_poll, poll_groups.group_id as group_of_id")
                .where("#{poll_group_query}").uniq
    @query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end
  
end