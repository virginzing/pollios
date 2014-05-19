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
    query =  Poll.joins(:poll_groups).uniq.
                  includes(:member, :poll_series, :campaign).
                  where("poll_groups.group_id IN (?)", your_group_ids).active_poll
    filter_type(query, type)
  end

  private

  def member_id
    params.fetch("member_id")
  end

  def type
    params.fetch("type") if params["type"]
  end
  
end