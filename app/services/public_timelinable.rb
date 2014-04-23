class PublicTimelinable
  attr_reader :params

  def initialize(params)
    @params = params
    @type = params["type"] || "all"
  end

  def my_hidden
    HiddenPoll.my_hidden_poll(member_id)
  end

  def filter_type(query, type)
    case type
      when "active" then query.where("poll_members.expire_date > ?", Time.now)
      when "inactive" then query.where("poll_members.expire_date < ?", Time.now)
      else query
    end
  end

  def poll_public
    @hidden_poll_ids = my_hidden
    if @hidden_poll_ids.empty?
      # query = Poll.unscoped.joins(:choices).select("polls.*, max(choices.vote) as vote_max, choices.answer as choice_answer").
      #               group("polls.id, choices.poll_id, choices.answer").order("vote_max desc, created_at desc").
      #               joins(:poll_members).includes(:member, :poll_series, :campaign).
      #               where("poll_members.public = ? AND share_poll_of_id = 0", true)
      query = Poll.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign).
                   where("poll_members.public = ? AND share_poll_of_id = 0 AND poll_members.in_group = ? AND poll_members.expire_date > ?", true, false, Time.now)
    else
    query = Poll.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign).
                 where("poll_members.public = ? AND poll_members.share_poll_of_id = 0 AND poll_members.poll_id NOT IN (?) AND poll_members.in_group = ? AND poll_members.expire_date > ?", true, @hidden_poll_ids, false, Time.now)
    end
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
