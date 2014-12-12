class V6::HashtagTimeline
  include GroupApi
  include Timelinable

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

  def get_hashtag_popular
    @hashtag_popular ||= tag_popular.map(&:name)
  end

  def get_timeline
    @hashtag ||= split_poll_and_filter(TYPE_TIMELINE)
  end

  def total_entries
    cached_poll_ids_of_poll_member(TYPE_TIMELINE).count
  end

  private

  def tag_popular
    query = Tag.joins(:taggings => [:poll => :poll_members]).
      where("polls.in_group_ids = '0'").
      where("polls.vote_all > 0").
      where("(polls.public = ?) OR (poll_members.member_id IN (?) AND poll_members.share_poll_of_id = 0 AND poll_members.series = 'f')", true, your_friend_ids).
      select("tags.*, count(taggings.tag_id) as count").
      group("taggings.tag_id, tags.id").
      order("count desc").limit(5)

    query = report_poll_filter(query)
    query = hidden_poll_filter(query)
    query = block_poll_filter(query)

    query
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
    query = PollMember.available.joins(:poll => :tags).includes([{:poll => [:choices, :campaign, :poll_series, :member, :poll_groups]}])
                      .where("tags.name = ?", query_tag)
                      .where("poll_members.share_poll_of_id = 0")
                      .where("(polls.order_poll = 1 AND polls.series = 'f' AND polls.in_group = 'f') " \
                      "OR (poll_groups.group_id IN (?) AND poll_groups.share_poll_of_id = 0)", your_group_ids).references(:poll_groups)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0

    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0

    query = query.limit(LIMIT_TIMELINE)

    query.map(&:id)
  end

  def main_timeline
    tag_friend_group_public
  end


end
