class V6::FriendFollowingTimeline
  include GroupApi
  include Timelinable
  
  TYPE_TIMELINE = 'friend_following_timeline'

  attr_accessor :list_polls, :list_shared, :order_ids, :next_cursor

  def initialize(member, options)
    @member = member
    @options = options
    @next_cursor = 0
    @list_polls = []
    @list_shared = []
    @order_ids = []
  end

  def your_friend_ids
    @friend_ids ||= Member.list_friend_active.map(&:id)
  end

  def your_following_ids
    @following_ids ||= Member.list_friend_following.map(&:id)
  end

  def get_timeline
    split_poll_and_filter(TYPE_TIMELINE)
  end

  def total_entries
    cached_poll_ids_of_poll_member(TYPE_TIMELINE).count
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
        your_following_ids)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0

    query = query.limit(LIMIT_TIMELINE)
    
    ids, poll_ids = query.map(&:id), query.map(&:poll_id)
  end

  def find_poll_share
    query_poll_shared = "poll_members.member_id IN (?) AND poll_members.share_poll_of_id <> 0 AND poll_members.in_group = 'f'"

    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_shared})" \
      "OR (#{query_poll_shared})", 
      your_friend_ids,
      your_following_ids)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids).limit(LIMIT_TIMELINE) if with_out_poll_ids.count > 0

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
    poll_member_ids_sort - check_poll_not_show_result
  end

  def main_timeline
    friend_following_timeline
  end

end