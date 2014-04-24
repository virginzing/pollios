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
    @member.get_group_active
  end

  def your_group_ids
    your_group.map(&:id)
  end

  def group_by_name
    Hash[your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def group_poll
    # query =  Poll.unscoped.joins(:choices).select("polls.*, max(choices.vote) as vote_max, choices.answer as choice_answer").
    #             group("polls.id, choices.poll_id, choices.answer").order("vote_max desc, created_at desc").
    #             joins(:poll_groups).uniq.
    #             includes(:member, :poll_series, :campaign).
    #             where("poll_groups.group_id IN (?)", your_group_ids)
    query =  Poll.joins(:poll_groups).uniq.
                  includes(:choices, :member, :poll_series, :campaign).
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