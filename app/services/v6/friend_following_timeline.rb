class V6::FriendFollowingTimeline
  include LimitPoll
  include GroupApi
  
  attr_accessor :next_cursor, :order_ids, :list_polls, :list_shared, :load_more

  def initialize(member_obj, options)
    @member = member_obj
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(member_obj.id)
    @order_ids = []
    @list_polls = []
    @list_shared = []
  end

  def member_id
    @member.id
  end

  def hidden_poll
    @hidden_poll
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
    
    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_me})" \
        "OR (#{query_poll_friend_and_following})" \
        "OR (#{query_poll_friend_and_following})" ,
        member_id,
        your_friend_ids,
        your_following_ids).limit(LIMIT_TIMELINE)

    ids, poll_ids = query.map(&:id), query.map(&:poll_id)
  end

  def find_poll_share
    query_poll_shared = "poll_members.member_id IN (?) AND poll_members.share_poll_of_id <> 0 AND poll_members.in_group = 'f'"

    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_shared})" \
      "OR (#{query_poll_shared})", 
      your_friend_ids,
      your_following_ids).limit(LIMIT_TIMELINE)

    query.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end
  
  def friend_following_timeline
    ids, poll_ids = find_poll_me_and_friend_following
    shared = find_poll_share
    poll_member_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
    poll_member_ids_sort - check_poll_not_show_result - hidden_poll
  end

  def check_poll_not_show_result
    Member.voted_polls.collect{|e| e["poll_id"] if e["show_result"] == false }.compact
  end

  def cached_poll_ids_of_poll_member
    @cache_poll_ids ||= Rails.cache.fetch([ 'friend_following_poll', member_id]) do
      friend_following_timeline
    end
  end

  def split_poll_and_filter
    next_cursor = @options["next_cursor"]

    if next_cursor.presence && next_cursor != "0"
      next_cursor = next_cursor.to_i
      @cache_polls ||= cached_poll_ids_of_poll_member

      if next_cursor.in? @cache_polls
        index = @cache_polls.index(next_cursor)
        @poll_ids = @cache_polls[(index+1)..(LIMIT_POLL+index)]
      else
        @cache_polls.select!{ |e| e < next_cursor }
        @poll_ids = @cache_polls[0..(LIMIT_POLL-1)] 
      end
    else
      Rails.cache.delete([ 'friend_following_poll', member_id ])
      @cache_polls ||= cached_poll_ids_of_poll_member
      @poll_ids = @cache_polls[0..(LIMIT_POLL - 1)]
    end

    if @cache_polls.count > LIMIT_POLL
      if @poll_ids.count == LIMIT_POLL
        if @cache_polls[-1] == @poll_ids.last
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

    filter_overall_timeline(next_cursor)
  end

  def filter_overall_timeline(next_cursor)
    poll_member = PollMember.includes([{:poll => [:groups, :choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).order("id desc")

    poll_member.each do |poll_member|
      if poll_member.share_poll_of_id == 0
        not_shared = Hash["shared" => false]
        list_polls << poll_member.poll
        list_shared << not_shared
      else
        find_poll = Poll.find_by(id: poll_member.share_poll_of_id)
        find_member_share = Member.joins(:share_polls).where("share_polls.poll_id = #{poll_member.poll_id}")
        shared = Hash["shared" => true, "shared_by" => serailize_member_detail_as_json(find_member_share), "shared_at" => poll_shared_at(poll_member) ]

        list_polls << find_poll
        list_shared << shared
      end
      order_ids << poll_member.id
    end

    [list_polls, list_shared, order_ids, next_cursor]
  end

end