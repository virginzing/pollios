class V6::HashtagTimeline
  include LimitPoll
  include GroupApi

  attr_accessor :next_cursor, :order_ids, :list_polls, :list_shared, :load_more

  def initialize(member, options)
    @member = member
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(member.id)
    @init_unsee_poll ||= UnseePoll.new( { member_id: member.id} )
    @init_save_poll ||= SavePoll.new( { member_id: member.id} )
    @order_ids = []
    @list_polls = []
    @list_shared = []
  end

  def my_group_id
    @my_group_ids ||= @my_group.map(&:id)
  end

  def member_id
    @member.id
  end

  def query_tag
    @options["name"]
  end

  def hidden_poll
    @hidden_poll
  end

  def original_next_cursor
    @original_next_cursor = @options[:next_cursor]
  end

  def list_my_friend_ids
    Member.list_friend_active.map(&:id) << @member.id
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e["poll_series_id"] != 0 }.collect{|e| e["poll_id"] }
  end

  def check_poll_not_show_result
    Member.voted_polls.collect{|e| e["poll_id"] if e["show_result"] == false }.compact
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

  def my_vote_poll_ids
    @poll_voted_ids ||= @member.cached_my_voted.select{|e| e["poll_series_id"] == 0 }.collect{|e| e["poll_id"] }
  end

  def with_out_poll_ids
    hidden_poll | check_poll_not_show_result | my_vote_questionnaire_ids | unsee_poll_ids | saved_poll_ids_later
  end

  def with_out_questionnaire_id
    unsee_questionnaire_ids | saved_questionnaire_ids_later
  end

  def get_hashtag
    @hashtag ||= split_poll_and_filter
  end

  def get_hashtag_popular
    @hashtag_popular ||= tag_popular.map(&:name)
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

    return query
  end

  def tag_friend_group_public
    query = PollMember.available.joins(:poll => :tags).includes([{:poll => [:choices, :campaign, :poll_series, :member]}])
                      .where("tags.name = ?", query_tag)
                      .where("poll_members.share_poll_of_id = 0")
                      .where("(polls.order_poll = 1 AND polls.series = 'f' AND polls.in_group = 'f') " \
                      "OR (poll_members.poll_id IN (?) AND poll_members.in_group = 't')", find_poll_in_my_group)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0

    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0

    query = query.limit(LIMIT_TIMELINE)

    query
  end

  def find_poll_in_my_group
    PollGroup.where("group_id IN (?)", your_group_ids).limit(LIMIT_TIMELINE).map(&:poll_id).uniq
  end

  # def poll_with_tag
  #   poll_without_group = "poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
  #   poll_with_group = "poll_members.poll_id IN (?) AND poll_members.in_group = 't' AND poll_members.share_poll_of_id = 0"

  #   query = Poll.available.unexpire.joins([:poll_members,:taggings => :tag]).uniq.

  #   where("((#{poll_without_group} AND #{poll_unexpire}) OR (#{poll_without_group} AND #{poll_expire_have_vote}))" \
  #     "OR ((#{poll_with_group} AND #{poll_unexpire}) OR (#{poll_with_group} AND #{poll_expire_have_vote}))",
  #     find_poll_in_my_group, find_poll_in_my_group).
  #   search_with_tag(query_tag).
  #   order("created_at desc, vote_all desc")
  # end

  def cached_poll_ids_of_poll_member
    @cache_poll_ids ||= Rails.cache.fetch([ 'hashtag_timeline', member_id]) do
      tag_friend_group_public
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
      Rails.cache.delete([ 'hashtag_timeline', member_id ])
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
    poll_member = PollMember.includes([{:poll => [:choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).order("id desc")

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

end
