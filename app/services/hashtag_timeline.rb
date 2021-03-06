class HashtagTimeline
  include LimitPoll

  def initialize(member_obj, options)
    @member = member_obj
    @options = options
    @report_poll = Member.current_member.cached_report_poll
    @block_member = Member.list_friend_block

    @init_list_friend = Member::MemberList.new(@member)
    @init_list_group = Member::GroupList.new(@member)
  end

  def member_id
    @member.id
  end

  def query_tag
    @options["name"]
  end

  def your_friend_ids
    @friend_ids ||= @init_list_friend.active.map(&:id) << member_id
  end

  def your_group
    @init_list_group.active
  end

  def your_group_ids
    your_group.map(&:id)
  end

  def group_by_name
    Hash[your_group.map{ |group| [group.id, GroupDetailSerializer.new(group).as_json] }]
  end

  def get_hashtag
    @hashtag ||= poll_with_tag
  end

  def get_hashtag_popular
    @hashtag_popular ||= tag_popular.map(&:name)
  end

  def get_recent_search_tags
    TypeSearch.find_search_tags(@member)
  end

  private

  def tag_popular
    query = Tag.joins(:taggings => [:poll => :poll_members]).
      where("polls.in_group_ids = '0'").
      where("polls.vote_all > 0").
      where("date(taggings.created_at + interval '7 hour') BETWEEN ? AND ?", Date.current.beginning_of_month, Date.current.end_of_month).
      where("(polls.public = ?) OR (poll_members.member_id IN (?) AND poll_members.share_poll_of_id = 0 AND poll_members.series = 'f')", true, your_friend_ids).
      select("tags.*, count(taggings.tag_id) as count").
      group("taggings.tag_id, tags.id").
      order("count desc").limit(10)

    query = report_poll_filter(query)
    query = block_poll_filter(query)

    return query
  end

  def report_poll_filter(query)
    query.where("polls.id NOT IN (?)", @report_poll.map(&:id)) if @report_poll.size > 0
    query
  end

  def block_poll_filter(query)
    query.where("polls.member_id NOT IN (?)", @block_member.map(&:id)) if @block_member.size > 0
    query
  end

  def tag_friend_group_public
    Tag.find_by_name(query_tag).polls.
    joins(:poll_members).
    includes(:poll_groups, :campaign, :choices, :member).
    where("polls.id NOT IN (?)", @report_poll.map(&:id)).
    where("(polls.public = ?) OR (poll_members.member_id IN (?) AND poll_members.in_group = ? AND poll_members.share_poll_of_id = 0) " \
          "OR (poll_groups.group_id IN (?))", true, your_friend_ids, false, your_group_ids).references(:poll_groups)
  end

  def poll_with_tag
    poll_without_group = "poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
    poll_with_group = "poll_members.poll_id IN (?) AND poll_members.in_group = 't' AND poll_members.share_poll_of_id = 0"

    query = Poll.available.unexpire.joins([:poll_members,:taggings => :tag]).uniq
                .where("((#{poll_without_group} AND #{poll_unexpire}) OR (#{poll_without_group} AND #{poll_expire_have_vote}))" \
                "OR ((#{poll_with_group} AND #{poll_unexpire}) OR (#{poll_with_group} AND #{poll_expire_have_vote}))",
                find_poll_in_my_group, find_poll_in_my_group).
                search_with_tag(query_tag).
                order("created_at desc, vote_all desc")
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  def find_poll_in_my_group
    query = PollGroup.where("group_id IN (?)", your_group_ids).limit(LIMIT_TIMELINE).map(&:poll_id).uniq
  end

end
