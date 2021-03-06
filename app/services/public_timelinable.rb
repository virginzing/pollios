class PublicTimelinable
  attr_reader :params

  def initialize(params, member)
    @params = params
    @type = params["type"] || "all"
    @pull_request = params["pull_request"] || "false"
    @member = member
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e[:poll_series_id] != 0 }.collect{|e| e[:poll_id] }
  end

  def since_id
    @params["since_id"] || 0
  end

  def filter_type(query, type)
    case type
    when "active" then query.where("poll_members.expire_date > ?", Time.now)
    when "inactive" then query.where("poll_members.expire_date < ?", Time.now)
    else query
    end
  end

  def poll_public

    query_poll_public = "poll_members.public = 't' AND share_poll_of_id = 0 AND poll_members.in_group = 'f'"

    query_poll_public_with_hidden = "poll_members.public = 't' AND poll_members.share_poll_of_id = 0 AND poll_members.poll_id NOT IN (?) AND poll_members.in_group = 'f'"

    query = Poll.available.unexpire.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign).
    where("(#{query_poll_public} AND #{poll_unexpire})")

    query = query.where("poll_id NOT IN (?)", my_vote_questionnaire_ids) if my_vote_questionnaire_ids.size > 0

    query
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

  def to_bool(request)
    return true   if request == "true"
    return false  if request == "false"
  end

end
