class PollRewardTimeline
  attr_reader :params
  
  def initialize(params)
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

  def reward_poll
    query =  Poll.joins(:poll_members).where("campaign_id != 0 AND poll_members.expire_date > ?", Time.now).includes(:choices, :member, :poll_series, :campaign)
    filter_type(query, type)
  end

  private

  def type
    params.fetch("type") if params["type"]
  end
  
  
end