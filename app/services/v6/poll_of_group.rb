class V6::PollOfGroup
  include GroupApi

  LIMIT_TIMELINE = 500
  LIMIT_POLL = 20

  attr_accessor :next_cursor

  def initialize(member, group, params = {})
    @member = member
    @group = group
    @params = params

    @member_poll_list = Member::PollList.new(@member)
  end

  def member_id
    @member.id
  end

  def group_id
    @group.id
  end

  def block_users
    Member::MemberList.new(@member).blocks.map(&:id)
  end

  def original_next_cursor
    @original_next_cursor = @params[:next_cursor]
  end

  def init_un_see_poll
    @init_un_see_poll ||= UnseePoll.new({ member_id: member_id})
  end

  def not_interested_poll_ids
    @member_poll_list.not_interested_poll_ids
  end

  def not_interested_questionnaire_ids
    @member_poll_list.not_interested_questionnaire_ids
  end

  def saved_poll_ids_later
    @member_poll_list.saved_poll_ids
  end

  def saved_questionnaire_ids_later
    @member_poll_list.saved_questionnaire_ids
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e[:poll_series_id] != 0 }.collect{|e| e[:poll_id] }
  end

  def with_out_member_ids
    block_users
  end

  def with_out_poll_ids
    my_vote_questionnaire_ids | not_interested_poll_ids | saved_poll_ids_later
  end

  def with_out_questionnaire_id
    not_interested_questionnaire_ids | saved_questionnaire_ids_later
  end

  def get_poll_of_group
    @poll_of_group ||= poll_of_group
  end

  def get_poll_available_of_group
    @poll_of_group ||= split_poll_and_filter
  end

  def get_poll_of_group_company
    @poll_of_group_company ||= poll_of_group_company
  end

  def get_questionnaire_of_group_company
    @questionnaire_of_group_company ||= questionnaire_of_group_company
  end

  private

  def poll_of_group
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    @query = Poll.order("updated_at DESC, created_at DESC").joins(:groups).includes(:choices, :history_votes, :member)
                  .select("polls.*, poll_groups.share_poll_of_id as share_poll, poll_groups.group_id as group_of_id")
                  .where("#{poll_group_query}").uniq
    @query
  end

  def api_poll_of_group(next_cursor = nil, limit_poll = LIMIT_POLL)
    poll_group_query = "poll_groups.group_id = #{@group.id}"
    query = Poll.except_qrcode.load_more(next_cursor).available.order("updated_at DESC, created_at DESC").joins(:groups).includes(:choices, :history_votes, :member)
                  .select("polls.*, poll_groups.share_poll_of_id as share_poll, poll_groups.group_id as group_of_id")
                  .where("(#{poll_group_query} AND #{poll_unexpire})").uniq

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.size > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.size > 0
    query = query.where("polls.member_id NOT IN (?)", with_out_member_ids) if with_out_member_ids.size > 0
    query = query.limit(limit_poll)
    query

  end

  def poll_of_group_company
    @query = Poll.unscoped.order("polls.created_at DESC")
                  .includes(:groups, :member)
                  .where("poll_groups.group_id IN (?) AND polls.series = 'f'", @group.map(&:id))
                  .includes(:history_votes)
    @query
  end

  def questionnaire_of_group_company
    @query = PollSeries.joins(:poll_series_group).unscoped.order("poll_series.created_at DESC").where("poll_series.group_id IN (?)", @group.map(&:id))
    @query
  end

  def poll_expire_have_vote
    "polls.expire_status = 't' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_status = 'f'"
  end

  def split_poll_and_filter
    @select_poll = api_poll_of_group(original_next_cursor)

    if original_next_cursor.presence && original_next_cursor != "0"
      @polls ||= get_cache_each_group
      set_next_cursor = original_next_cursor.to_i

      if set_next_cursor.in? @polls
        index = @polls.index(set_next_cursor)
        @poll_ids = @polls[(index+1)..(LIMIT_POLL+index)]
      else
        @polls.select!{ |e| e < set_next_cursor }
        @poll_ids = @polls[0..(LIMIT_POLL-1)] 
      end

    else
      delete_cache_each_group
      @polls = get_cache_each_group
      @poll_ids = @polls[0..(LIMIT_POLL - 1)]
    end

    if @polls.size > LIMIT_POLL
      if @poll_ids.size == LIMIT_POLL
        if @polls[-1] == @poll_ids.last
          next_cursor = 0
        else
          next_cursor = @poll_ids.last
        end
      else
        next_cursor = 0
      end
    else
      next_cursor = 0
    end

    [@select_poll, next_cursor]
  end

  def get_cache_each_group
    Rails.cache.fetch([ member_id, 'with_group', group_id]) do
      api_poll_of_group(nil, 1000).to_a.map(&:id)
    end
  end

  def delete_cache_each_group
    Rails.cache.delete([ member_id, 'with_group', group_id])
  end

end