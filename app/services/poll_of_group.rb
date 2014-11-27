class PollOfGroup
  include GroupApi

  attr_accessor :poll_series, :poll_nonseries, :series_shared, :nonseries_shared

  def initialize(member, group, params = {}, web = false)
    @member = member
    @group = group
    @params = params
    @poll_series = []
    @poll_nonseries = []
    @series_shared = []
    @nonseries_shared = []
    @only_poll_available = false
    @web = web
  end

  def group_id
    @params["id"]
  end

  def get_poll_of_group
    @poll_of_group ||= poll_of_group
  end

  def get_poll_available_of_group
    @poll_of_group ||= api_poll_of_group
  end

  def get_poll_of_group_company
    @poll_of_group_company ||= poll_of_group_company
  end

  def get_questionnaire_of_group_company
    @questionnaire_of_group_company ||= questionnaire_of_group_company
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e["poll_series_id"] != 0 }.collect{|e| e["poll_id"] }
  end

  private

  def poll_of_group
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    @query = Poll.order("updated_at DESC, created_at DESC").joins(:groups).includes(:history_votes, :member)
                  .select("polls.*, poll_groups.share_poll_of_id as share_poll, poll_groups.group_id as group_of_id")
                  .where("#{poll_group_query}").uniq
    @query
  end

  def api_poll_of_group
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    query = Poll.available.order("updated_at DESC, created_at DESC").joins(:groups).includes(:history_votes, :member)
                  .select("polls.*, poll_groups.share_poll_of_id as share_poll, poll_groups.group_id as group_of_id")
                  .where("#{poll_group_query}").uniq

    query = query.where("polls.id NOT IN (?)", my_vote_questionnaire_ids) if my_vote_questionnaire_ids.count > 0

    query
  end

  def poll_of_group_company
    @query = Poll.unscoped.select('polls.*')
                  .eager_load(:groups, :member)
                  .where("poll_groups.group_id IN (?)", @group.map(&:id)).uniq
                  .includes(:history_votes)
                  .order("polls.created_at DESC")
    @query = @query.where("polls.series = 'f'") if @web == true
    @query
  end

  def questionnaire_of_group_company
    @query = PollSeries.joins(:poll_series_group).unscoped.order("poll_series.created_at DESC").where("poll_series.group_id IN (?)", @group.map(&:id))
    @query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

end
