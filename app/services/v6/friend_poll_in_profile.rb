class V6::FriendPollInProfile
  include LimitPoll

  attr_accessor :next_cursor

  def initialize(member, friend, options)
    @member = member
    @friend = friend
    @options = options
    @friend_group = @friend.cached_get_group_active
    @my_group = Member.list_group_active
    @init_unsee_poll ||= UnseePoll.new( { member_id: member.id} )
    @init_save_poll ||= SavePoll.new( { member_id: member.id} )
  end
  
  def friend_id
    @friend.id
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

  def my_group_id
    @my_group_ids ||= @my_group.map(&:id)  
  end

  def friend_group_id
    @friend_group_ids ||= @friend_group.map(&:id)
  end

  def my_and_friend_group
    my_group_id & friend_group_id
  end

  def list_my_friend_ids
    Member.list_friend_active.map(&:id) << @member.id
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e["poll_series_id"] != 0 }.collect{|e| e["poll_id"] }
  end

  def is_friend
    list_my_friend_ids.include?(friend_id) ? friend_id : 0
  end

  def group_by_name
    Hash[@friend_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def with_out_poll_ids
    my_vote_questionnaire_ids | unsee_poll_ids | saved_poll_ids_later
  end

  def with_out_questionnaire_id
    unsee_questionnaire_ids | saved_questionnaire_ids_later
  end

  def get_poll_friend
    @poll_created ||= poll_created 
  end

  def get_vote_friend
    @poll_voted ||= poll_voted
  end

  def get_watched_friend
    @poll_watched ||= poll_watched
  end

  def get_poll_friend_with_visibility
    @poll_created_visibility ||= poll_created_with_visibility(nil, nil)
  end

  def get_vote_friend_with_visibility
    @poll_voted_visibility ||= poll_voted_with_visibility(nil, nil)
  end

  def get_watched_friend_with_visibility
    @poll_watched_visibility ||= poll_watched_with_visibility(nil, nil)
  end

  def get_friend_poll_feed
    split_poll_and_filter("poll_created")
  end

  def get_friend_vote_feed
    split_poll_and_filter("poll_voted")
  end

  def get_friend_watch_feed
    split_poll_and_filter("poll_watched")
  end

  def poll_friend_count
    poll_created_with_visibility.count
  end

  def vote_friend_count
    poll_voted_with_visibility.count
  end

  def watched_friend_count
    poll_watched_with_visibility.count
  end

  def group_friend_count
    mutual_or_public_group.map(&:id).uniq.count
  end

  def block_friend_count
    block_friend.count
  end

  private

  def poll_created
    query_poll_member = "poll_members.member_id = #{friend_id} AND poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "poll_members.member_id = #{friend_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "poll_members.public = 't' AND poll_members.member_id = #{friend_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups).
                where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})", 
                my_and_friend_group, my_and_friend_group).references(:poll_groups)
  end

  def poll_voted
    query = Poll.not_qr_only.available.joins(:history_votes).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(history_votes.member_id = #{friend_id} AND polls.member_id IN (?) AND polls.in_group = 'f') " \
                "OR (history_votes.member_id = #{friend_id} AND polls.public = 't') " \
                "OR (history_votes.member_id = #{friend_id} AND poll_groups.group_id IN (?))", 
                (list_my_friend_ids << friend_id),
                my_and_friend_group).references(:poll_groups)
  end

  def poll_watched
    query = Poll.available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(watcheds.member_id = #{friend_id} AND polls.member_id IN (?) AND polls.in_group_ids = '0')" \
                "OR (watcheds.member_id = #{friend_id} AND polls.public = 't') " \
                "OR (watcheds.member_id = #{friend_id} AND poll_groups.group_id IN (?))", (list_my_friend_ids << friend_id), my_and_friend_group).references(:poll_groups)
  end

  def poll_created_with_visibility(next_cursor = nil, limit_poll = LIMIT_POLL)
    query_poll_member = "polls.member_id = #{is_friend} AND polls.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_group_together = "polls.member_id = #{friend_id} AND poll_groups.group_id IN (?) AND poll_members.share_poll_of_id = 0"
    query_public = "polls.public = 't' AND polls.member_id = #{friend_id} AND poll_members.share_poll_of_id = 0"

    query = Poll.load_more(next_cursor).available.joins(:poll_members).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
                .where("(#{query_poll_member} AND #{poll_unexpire}) OR (#{query_poll_member} AND #{poll_expire_have_vote})" \
                "OR (#{query_group_together} AND #{poll_unexpire}) OR (#{query_group_together} AND #{poll_expire_have_vote})" \
                "OR (#{query_public} AND #{poll_unexpire}) OR (#{query_public} AND #{poll_expire_have_vote})", 
                my_and_friend_group, my_and_friend_group).references(:poll_groups)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0
    query = query.limit(limit_poll)
    query
  end

  def poll_voted_with_visibility(next_cursor = nil, limit_poll = LIMIT_POLL)
    query = Poll.without_my_poll(friend_id).load_more(next_cursor).available.joins(:history_votes).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
            .where("(history_votes.member_id = #{is_friend} AND polls.in_group = 'f') " \
            "OR (history_votes.member_id = #{friend_id} AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)" \
            "OR (history_votes.member_id = #{friend_id} AND poll_groups.group_id IN (?))",
            my_and_friend_group).references(:poll_groups)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0
    query = query.limit(limit_poll)
    query
  end

  def poll_watched_with_visibility(next_cursor = nil, limit_poll = LIMIT_POLL)
    query = Poll.load_more(next_cursor).available.joins(:watcheds).includes(:choices, :member, :poll_series, :campaign, :poll_groups)
            .where("(watcheds.member_id = #{friend_id} AND watcheds.poll_notify = 't')")
            .where("(watcheds.member_id = #{friend_id} AND polls.in_group = 'f')" \
            "OR (watcheds.member_id = #{friend_id} AND polls.public = 't') " \
            "OR (watcheds.member_id = #{friend_id} AND poll_groups.group_id IN (?))", my_and_friend_group)
            .order("watcheds.created_at DESC")
            .references(:poll_groups)
            
    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.limit(limit_poll)
    query
  end

  def block_friend
    query = @friend.get_friend_blocked
  end

  def mutual_or_public_group
    query = Group.joins(:group_members_active).where("(groups.id IN (?)) OR (group_members.active = 't' AND groups.public = 't' AND group_members.member_id = #{friend_id})", my_and_friend_group)
                .includes(:polls_active)
                .select("groups.*")
                .group("groups.id, polls.id, members.id")
                .order("groups.name asc")
                .references(:polls_active)
    query
  end

  def my_group
    query = Group.joins(:group_members_active).where("groups.id IN (?)", my_group_id)
                .includes(:polls_active)
                .select("groups.*, count(group_members.group_id) as member_in_group")
                .group("groups.id, polls.id, members.id").order("groups.name asc")
                .references(:polls_active)
    query
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  def split_poll_and_filter(type_feed)
    @type_feed = type_feed

    @select_poll = if @type_feed == "poll_created"
      poll_created_with_visibility(original_next_cursor)
    elsif @type_feed == "poll_voted"
      poll_voted_with_visibility(original_next_cursor)
    else
      poll_watched_with_visibility(original_next_cursor)
    end

    if original_next_cursor.presence && original_next_cursor != "0"
      @polls ||= get_type_of_poll_feed
      set_next_cursor = original_next_cursor.to_i

      if set_next_cursor.in? @polls
        index = @polls.index(set_next_cursor)
        @poll_ids = @polls[(index+1)..(LIMIT_POLL+index)]
      else
        @polls.select!{ |e| e < set_next_cursor }
        @poll_ids = @polls[0..(LIMIT_POLL-1)] 
      end

    else
      delete_cache_tpye_of_poll_feed
      @polls = get_type_of_poll_feed
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
      when "poll_created" then poll_with_friend_created
      when "poll_voted" then poll_with_friend_voted
      when "poll_watched" then poll_with_friend_watched
    end
  end

  def poll_with_friend_created
    Rails.cache.fetch([@member.id, 'poll_visible_with', @friend.id]) do
      poll_created_with_visibility(nil, 1000).to_a.map(&:id)
    end
  end

  def poll_with_friend_voted
    Rails.cache.fetch([@member.id, 'vote_visible_with', @friend.id]) do
      poll_voted_with_visibility(nil, 1000).to_a.map(&:id)
    end
  end

  def poll_with_friend_watched
    Rails.cache.fetch([@member.id, 'watch_visible_with', @friend.id]) do
      poll_watched_with_visibility(nil, 1000).to_a.map(&:id)
    end
  end

  def delete_cache_tpye_of_poll_feed
    case @type_feed
      when "poll_created" then flush_poll_with_friend_created
      when "poll_voted" then flush_poll_with_friend_voted
      when "poll_watched" then flush_poll_with_friend_watched
    end
  end

  def flush_poll_with_friend_created
    Rails.cache.delete([@member.id, 'poll_visible_with', @friend.id])
  end

  def flush_poll_with_friend_voted
    Rails.cache.delete([@member.id, 'vote_visible_with', @friend.id])
  end

  def flush_poll_with_friend_watched
    Rails.cache.delete([@member.id, 'watch_visible_with', @friend.id])
  end

  
end

