class GroupTimelinable
  attr_reader :params

  def initialize(params, member_obj)
    @params = params
    @member = member_obj
    @type = params["type"] || "all"
  end


  def filter_type(query, type)
    case type
      when "active" then query.where("expire_date > ?", Time.now)
      when "inactive" then query.where("expire_date < ?", Time.now)
      else query
    end
  end

  def your_group
    @member.get_group_active.map(&:id)
  end

  def group_poll
    query = Poll.joins(:poll_groups).uniq
                .includes(:member, :poll_series, :campaign)
                .where("poll_groups.group_id IN (?)", your_group)
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