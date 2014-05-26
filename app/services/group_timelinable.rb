class GroupTimelinable
  include GroupApi
  attr_reader :params

  def initialize(member, params)
    @member = member
    @params = params
    @type = params["type"] || "all"
  end

  def filter_type(query, type)
    case type
      when "active" then query.where("expire_date > ?", Time.now)
      when "inactive" then query.where("expire_date < ?", Time.now)
      else query
    end
  end

  def group_poll
    query_group_poll = "poll_groups.group_id IN (?)"

    query =  Poll.joins(:poll_groups).uniq.
                  includes(:member, :poll_series, :campaign).
                  where("(#{query_group_poll} AND #{poll_expire_have_vote}) OR (#{query_group_poll} AND #{poll_unexpire})", your_group_ids, your_group_ids)
    # filter_type(query, type)
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  private

  def member_id
    params.fetch("member_id")
  end

  def type
    params.fetch("type") if params["type"]
  end
  
end