class PollOfGroup
  include GroupApi

  def initialize(member, group, params = {})
    @member = member
    @group = group
    @params = params
  end

  def group_id
    @params["id"]
  end

  def get_poll_of_group
    @poll_of_group ||= poll_of_group
  end
  
  private

  def poll_of_group
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    query = Poll.available.joins(:poll_groups).where("(#{poll_group_query} AND #{poll_unexpire}) OR (#{poll_group_query} AND #{poll_expire_have_vote})")
    query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end
  
end
