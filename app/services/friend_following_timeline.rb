class FriendFollowingTimeline
  include LimitPoll
  include GroupApi
  
  attr_accessor :poll_series, :poll_nonseries, :series_shared, :nonseries_shared, :next_cursor

  def initialize(member_obj, options)
    @member = member_obj
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(member_obj.id)
    @poll_series = []
    @poll_nonseries = []
    @series_shared = []
    @nonseries_shared = []
  end

  def member_id
    @member.id
  end

  def your_friend_ids
    @friend_ids ||= @member.cached_get_friend_active.map(&:id)
  end

  def your_following_ids
    @following_ids ||= @member.cached_get_following.map(&:id)
  end

  def poll_friend_following
    @overall_timeline ||= split_poll_and_filter
  end

  def total_entries
    cached_poll_ids_of_poll_member.count
  end
  
  private

  def find_poll_me_and_friend_following
    query_poll_me = "poll_members.member_id = ? AND poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    query_poll_friend_and_following = "poll_members.member_id IN (?) AND poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    
    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_me} AND #{poll_unexpire})" \
        "OR (#{query_poll_friend_and_following} AND #{poll_unexpire})" \
        "OR (#{query_poll_friend_and_following} AND #{poll_unexpire})" ,
        member_id,
        your_friend_ids,
        your_following_ids).limit(LIMIT_TIMELINE)

      poll_member = check_hidden_poll(query)
      ids, poll_ids = poll_member.map(&:id), poll_member.map(&:poll_id)
  end

  def find_poll_share
    query_poll_shared = "poll_members.member_id IN (?) AND poll_members.share_poll_of_id <> 0 AND poll_members.in_group = 'f'"

    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_shared} AND #{poll_unexpire})" \
      "OR (#{query_poll_shared} AND #{poll_unexpire})", 
      your_friend_ids,
      your_following_ids).limit(LIMIT_TIMELINE)

    poll_member = check_hidden_poll(query)
    poll_member.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end
  
  def check_hidden_poll(query)
    @hidden_poll.empty? ? query : query.hidden(@hidden_poll)
  end

  def friend_following_timeline
    ids, poll_ids = find_poll_me_and_friend_following
    shared = find_poll_share
    poll_member_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
  end

  def cached_poll_ids_of_poll_member
    @cache_poll_ids ||= Rails.cache.fetch([ ENV["FRIEND_FOLLOWING_POLL"], member_id]) do
      friend_following_timeline
    end
  end

  def split_poll_and_filter
    next_cursor = @options["next_cursor"]

    if next_cursor.presence && next_cursor != "0"
      next_cursor = next_cursor.to_i
      cache_polls = cached_poll_ids_of_poll_member
      index = cache_polls.index(next_cursor)
      index = -1 if index.nil?
      @poll_ids = cache_polls[(index+1)..(LIMIT_POLL+index)]
    else
      Rails.cache.delete([ ENV["FRIEND_FOLLOWING_POLL"], member_id ])
      cache_polls = cached_poll_ids_of_poll_member
      @poll_ids   = cache_polls[0..(LIMIT_POLL - 1)]
    end

    if cache_polls.count > LIMIT_POLL
      if @poll_ids.count == LIMIT_POLL
        if cache_polls[-1] == @poll_ids.last
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

    filter_friend_following_timeline(next_cursor)
  end

  def filter_friend_following_timeline(next_cursor)
    poll_member = PollMember.includes([{:poll => [:choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).order("id desc")

    poll_member.each do |poll_member|
      if poll_member.share_poll_of_id == 0
        not_shared = Hash["shared" => false]
        if poll_member.poll.series
          poll_series << poll_member.poll
          series_shared << not_shared
        else
          poll_nonseries << poll_member.poll
          nonseries_shared << not_shared
        end
      else
        find_poll = Poll.find_by(id: poll_member.share_poll_of_id)
        shared = Hash["shared" => true, "shared_by" => poll_member.member.as_json()]
        if find_poll.present?
          if find_poll.series
            poll_series << find_poll
            series_shared << shared
          else
            poll_nonseries << find_poll
            nonseries_shared << shared
          end
        end
      end
    end
    [poll_series, series_shared, poll_nonseries, nonseries_shared, next_cursor]
  end

end