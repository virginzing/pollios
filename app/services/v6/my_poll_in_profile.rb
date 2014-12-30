class V6::MyPollInProfile
  include LimitPoll
  include GroupApi

  attr_accessor :next_cursor
  
  def initialize(member, options = nil)
    @member = member
    @options = options
    @init_unsee_poll ||= UnseePoll.new({ member_id: member.id})
    @init_save_poll ||= SavePoll.new( { member_id: member.id} )
  end

  def member_id
    @member.id
  end

  def original_next_cursor
    @original_next_cursor = @options[:next_cursor]
  end

  def unsee_poll_ids
    @init_unsee_poll.get_list_poll_id
  end

  def unsee_questionnaire_ids
    @init_unsee_poll.get_list_questionnaire_id
  end

  def saved_poll_ids_later
    @init_save_poll.get_list_poll_id
  end

  def saved_questionnaire_ids_later
    @init_save_poll.get_list_questionnaire_id
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e["poll_series_id"] != 0 }.collect{|e| e["poll_id"] }
  end

  def with_out_poll_ids
    unsee_poll_ids | saved_poll_ids_later
  end

  def with_out_questionnaire_id
    unsee_questionnaire_ids
  end

  # Filter with out poll & questionnaire

  def my_poll
    @my_poll ||= poll_created(nil, nil)
  end

  def get_my_poll
    split_poll_and_filter("poll_created")
  end

  def my_vote
    @my_vote ||= poll_voted(nil, nil)
  end

  def get_my_vote
    split_poll_and_filter("poll_voted")
  end

  def my_watched
    @my_watched ||= poll_watched(nil, nil)
  end

  def get_my_watch
    split_poll_and_filter("poll_watched")
  end

  def get_my_save_later
    split_poll_and_filter("poll_saved")
  end

  ## create ##

  def create_public_poll
    my_poll.select{|p| p.public == true }.count
  end

  def create_friend_following_poll
    my_poll.select{|p| p.public == false && p.in_group == false }.count
  end

  def create_group_poll
    my_poll.select{|p| p.in_group == true }.count
  end

  ## vote ##

  def vote_public_poll
    my_vote.select{|p| p.public == true }.count
  end

  def vote_friend_following_poll
    my_vote.select{|p| p.public == false && p.in_group == false }.count
  end

  def vote_group_poll
    my_vote.select{|p| p.in_group == true }.count
  end

  ## watched ##

  def watch_public_poll
    my_watched.select{|p| p.public == true }.count
  end

  def watch_friend_following_poll
    my_watched.select{|p| p.public == false && p.in_group == false }.count
  end

  def watch_group_poll
    my_watched.select{|p| p.in_group == true }.count
  end

  private

  # main query #

  def poll_created(next_cursor = nil, limit_poll = LIMIT_POLL)
    query_poll_member = "polls.member_id = #{member_id} AND polls.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "polls.member_id = #{member_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "polls.public = 't' AND polls.member_id = #{member_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.load_more(next_cursor).available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                       "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                       "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})",
                       your_group_ids, your_group_ids).references(:poll_groups)
    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.limit(limit_poll)
    query
  end

  def poll_voted(next_cursor = nil, limit_poll = LIMIT_POLL)
    query = Poll.without_my_poll(member_id).load_more(next_cursor).available.joins(:history_votes => :choice).includes(:member, :poll_series, :campaign, :poll_groups)
                .select("polls.*, history_votes.choice_id as choice_id")
                .where("(history_votes.member_id = #{member_id} AND polls.in_group = 'f') " \
                       "OR (history_votes.member_id = #{member_id} AND history_votes.poll_series_id != 0 AND polls.order_poll = 1 AND polls.qr_only = 'f')" \
                       "OR (history_votes.member_id = #{member_id} AND poll_groups.group_id IN (?))",
                       your_group_ids).references(:poll_groups)    
    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0
    query = query.limit(limit_poll)
    query
  end

  def poll_watched(next_cursor = nil, limit_poll = LIMIT_POLL)
    query = Poll.load_more(next_cursor).available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(watcheds.member_id = #{member_id} AND watcheds.poll_notify = 't')")
                .where("(watcheds.member_id = #{member_id} AND polls.in_group = 'f')" \
                       "OR (watcheds.member_id = #{member_id} AND polls.public = 't') " \
                       "OR (watcheds.member_id = #{member_id} AND poll_groups.group_id IN (?))", your_group_ids)
                .order("watcheds.created_at DESC")
                .references(:poll_groups)
    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0
    query = query.limit(limit_poll)
    query
  end

  def poll_saved(next_cursor = nil, limit_poll = LIMIT_POLL)
    query = Poll.load_more(next_cursor).available.includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(polls.poll_series_id IN (?) AND polls.order_poll = 1 AND polls.series = 't') " \
                  "OR (polls.id IN (?) AND polls.series = 'f')", saved_questionnaire_ids_later, saved_poll_ids_later)

    query = query.where("polls.id NOT IN (?)", unsee_poll_ids) if unsee_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0
    query = query.limit(limit_poll)
    query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  # make to timeline #

  def split_poll_and_filter(type_feed)
    @type_feed = type_feed

    @select_poll = if @type_feed == "poll_created"
      poll_created(original_next_cursor)
    elsif @type_feed == "poll_voted"
      poll_voted(original_next_cursor)
    elsif @type_feed == "poll_saved"
      poll_saved(original_next_cursor)
    else
      poll_watched(original_next_cursor)
    end

    if original_next_cursor.presence && original_next_cursor != "0"
      @polls ||= get_type_of_poll_feed.to_a
      set_next_cursor = original_next_cursor.to_i

      if set_next_cursor.in? @polls
        index = @polls.index(set_next_cursor)
        @poll_ids = @polls[(index+1)..(LIMIT_POLL+index)]
      else
        @polls.select!{ |e| e < set_next_cursor }
        @poll_ids = @polls[0..(LIMIT_POLL-1)] 
      end

    else
      @polls = update_type_of_poll_feed.to_a
      @poll_ids = @polls[0..(LIMIT_POLL - 1)]
    end

    if @polls.count > LIMIT_POLL
      if @poll_ids.count == LIMIT_POLL
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

  def get_type_of_poll_feed     
    case @type_feed
      when "poll_created" then poll_with_my_created
      when "poll_voted" then poll_with_my_voted
      when "poll_watched" then poll_with_my_watched
      when "poll_saved" then poll_with_my_saved
    end
  end

  def poll_with_my_created
    MemberPollFeed.where(member_id: member_id).first.poll_created_feed.lazy
  end

  def poll_with_my_voted
    MemberPollFeed.where(member_id: member_id).first.poll_voted_feed.lazy
  end

  def poll_with_my_watched
    MemberPollFeed.where(member_id: member_id).first.poll_watched_feed.lazy
  end

  def poll_with_my_saved
    MemberPollFeed.where(member_id: member_id).first.poll_saved_feed.lazy
  end

  def update_type_of_poll_feed
    case @type_feed
      when "poll_created" then poll_created_update_feed
      when "poll_voted" then poll_voted_update_feed
      when "poll_watched" then poll_watched_update_feed
      when "poll_saved" then poll_saved_update_feed
    end
  end

  def poll_created_update_feed
    check_new_record_feed
    @member_poll_feed.update!(poll_created_feed: poll_created(nil, 1000).to_a.map(&:id))
    @member_poll_feed.poll_created_feed.lazy
  end

  def poll_voted_update_feed
    check_new_record_feed
    @member_poll_feed.update!(poll_voted_feed: poll_voted(nil, 1000).to_a.map(&:id))
    @member_poll_feed.poll_voted_feed.lazy
  end

  def poll_watched_update_feed
    check_new_record_feed
    @member_poll_feed.update!(poll_watched_feed: poll_watched(nil, 1000).to_a.map(&:id))
    @member_poll_feed.poll_watched_feed.lazy
  end

  def poll_saved_update_feed
    check_new_record_feed
    @member_poll_feed.update!(poll_saved_feed: poll_saved(nil, 1000).to_a.map(&:id))
    @member_poll_feed.poll_saved_feed.lazy
  end

  def check_new_record_feed
    @member_poll_feed = MemberPollFeed.where(member_id: member_id).first_or_create do |member_poll_feed|
      member_poll_feed.member_id = member_id
    end
  end

end
