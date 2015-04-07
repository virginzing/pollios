class V6::HashtagTimeline
  include GroupApi
  include Timelinable
  include FeedSetting

  TYPE_TIMELINE = 'hashtag_timeline'

  attr_accessor :list_polls, :list_shared, :order_ids, :next_cursor

  def initialize(member, options)
    @member = member
    @options = options
    @next_cursor = 0
    @list_polls = []
    @list_shared = []
    @order_ids = []
  end

  def query_tag
    @options["name"]
  end

  def your_friend_ids
    @friend_ids ||= Member.list_friend_active.map(&:id)
  end

  def your_following_ids
    @following_ids ||= Member.list_friend_following.map(&:id)
  end

  def get_recent_tags_popular_names
    @recent_tags_popular_ids ||= recent_tags_popular.map(&:name)
  end

  def get_hashtag_popular
    @hashtag_popular ||= (get_recent_tags_popular_names | cached_tags_popular_names)
  end

  def get_timeline
    @hashtag ||= split_poll_and_filter(TYPE_TIMELINE)
  end

  def total_entries
    cached_poll_ids_of_poll_member(TYPE_TIMELINE).count
  end

  def get_recent_search_tags
    TypeSearch.find_search_tags(@member)
  end

  private

  # def tag_popular
  #   query = Tag.joins(:taggings => [:poll => :poll_members]).
  #     where("polls.in_group_ids = '0'").
  #     where("polls.vote_all > 0").
  #     where("(polls.public = ?) OR (poll_members.member_id IN (?) AND poll_members.share_poll_of_id = 0 AND poll_members.series = 'f')", true, your_friend_ids).
  #     select("tags.*, count(taggings.tag_id) as count").
  #     group("taggings.tag_id, tags.id").
  #     order("count desc").limit(5)

  #   query
  # end

  def tags_popular
    Tag.joins(:taggings => [:poll => :poll_members]).select("tags.*, count(taggings.tag_id) as count") \
        .where("polls.expire_status = 'f' AND polls.vote_all > 0 AND polls.in_group_ids = '0' AND polls.series = 'f'") \
        .where("date(taggings.created_at + interval '7 hour') BETWEEN ? AND ?", 60.days.ago.to_date, Date.yesterday) \
        .group("taggings.tag_id, tags.id") \
        .order("count desc").limit(10)
  end

  def cached_tags_popular_names
    Rails.cache.fetch('tags_popular') { tags_popular.map(&:name) }
  end

  def recent_tags_popular
    Tag.joins(:taggings => [:poll => :poll_members]).select("tags.*, count(taggings.tag_id) as count") \
        .where("polls.series = 'f'") \
        .where("polls.vote_all > 0 AND polls.in_group = 'f'") \
        .where("date(taggings.created_at + interval '7 hour') BETWEEN ? AND ?", Date.current, Date.current) \
        .group("taggings.tag_id, tags.id") \
        .order("count desc").limit(10)
  end

  def report_poll_filter(query)
    query.where("polls.id NOT IN (?)", @report_poll.map(&:id)) if @report_poll.count > 0
    query
  end

  def hidden_poll_filter(query)
    query.where("polls.id NOT IN (?)", @hidden_poll.map(&:id)) if @hidden_poll.count > 0
    query
  end

  def block_poll_filter(query)
    query.where("polls.member_id NOT IN (?)", @block_member.map(&:id)) if @block_member.count > 0
    query
  end

  def tag_friend_group_public
    feed = []
    priority = []
    created_time = []
    updated_time = []

    poll_friend_query = "poll_members.member_id IN (?) AND polls.public = 'f'"
    poll_group_query = "poll_groups.group_id IN (?)"
    poll_public_query = "(poll_members.public = 't')"

    new_your_friend_ids = ((your_friend_ids | your_following_ids) << member_id)

    # query = PollMember.available.unexpire.joins(:poll => :tags).includes( :poll => [:poll_groups])
    #                   .where("polls.series = 'f'")
    #                   .where("tags.name = ?", query_tag)
    #                   .where("(#{poll_friend_query})" \
    #                            "OR (#{poll_group_query})" \
    #                            "OR (#{poll_public_query})",
    #                            new_your_friend_ids,
    #                            your_group_ids).references(:poll_groups)

    query = PollMember.available.unexpire.joins(:poll => :tags).includes( :poll => [:poll_groups])
                      .where("polls.series = 'f'")
                      .where("tags.name = ?", query_tag)
                      .where("(polls.in_group = 'f') OR (polls.in_group = 't' AND poll_groups.group_id IN (?))", your_group_ids).references(:poll_groups)         

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0

    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0

    query.each do |q|
      priority << check_poll_priority(q.poll)
      feed << check_feed_type(q.poll)
      created_time << q.poll.created_at
      updated_time << q.poll.updated_at
    end

    ids, poll_ids, feed, priority, created_time, updated_time = query.map(&:id), query.map(&:poll_id), feed, priority, created_time, updated_time
  end

  def main_timeline
    # tag_friend_group_public
    ids, poll_ids, feed, priority, created_time, updated_time = tag_friend_group_public

    ids = FeedAlgorithm.new(ids, poll_ids, feed, priority, created_time, updated_time).sort_by_priority

    ids

  end


end
