class PublicTimelinable
  attr_reader :params

  def initialize(params, member)
    @params = params
    @type = params["type"] || "all"
    @pull_request = params["pull_request"] || "false"
    @member = member
  end

  def my_hidden
    HiddenPoll.my_hidden_poll(member_id)
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
    @hidden_poll_ids = my_hidden

    query_poll_public = "poll_members.public = 't' AND share_poll_of_id = 0 AND poll_members.in_group = 'f'"

    query_poll_public_with_hidden = "poll_members.public = 't' AND poll_members.share_poll_of_id = 0 AND poll_members.poll_id NOT IN (?) AND poll_members.in_group = 'f'" 

    poll_expire_have_vote = "polls.expire_date < '#{Time.now}' AND polls.vote_all != 0"

    if @hidden_poll_ids.empty?

      query = Poll.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign).
                   where("( #{query_poll_public} AND polls.expire_date > '#{Time.now}') OR ( #{query_poll_public} AND #{poll_expire_have_vote})")
    else
      query = Poll.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign).
                  where(" ( #{query_poll_public_with_hidden} AND poll_members.expire_date > '#{Time.now}') OR  (#{query_poll_public_with_hidden} AND #{poll_expire_have_vote} )",
                  @hidden_poll_ids, @hidden_poll_ids)
    end

    if to_bool(@pull_request)
      query = query.where("polls.id > ? AND polls.updated_at > ?", since_id, @member.poll_public_req_at)
    end 
    # filter_type(query, type)
    query
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
