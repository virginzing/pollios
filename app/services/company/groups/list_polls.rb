class Company::Groups::ListPolls
  def initialize(group)
    @group = group
  end

  def all
    @all ||= query_poll_in_group
  end

  private

  def query_poll_in_group
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    Poll.except_series.without_deleted.joins(:poll_groups).includes(:groups, :choices, :history_votes, :member, :poll_series)
                  .where("#{poll_group_query}")
                  .order("polls.updated_at DESC, polls.created_at DESC").uniq
  end

end

