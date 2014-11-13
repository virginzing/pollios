class V6::OverallTimeline
  include GroupApi
  include LimitPoll

  attr_accessor :next_cursor, :order_ids, :list_polls, :list_shared, :load_more

  def initialize(member, options)
    @member = member
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(member.id)
    @pull_request = options["pull_request"] || "no"
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

  def since_id
    @options["since_id"] || 0
  end

  def filter_my_poll
    @options[:my_poll].presence || "0"
  end

  def filter_my_vote
    @options[:my_vote].presence || "0"
  end


  def filter_public
    @options[:public].presence || "1"
  end

  def filter_friend_following
    @options[:friend_following].presence || "1"
  end

  def filter_group
    @options[:group].presence || "1"
  end

  def filter_reward
    @options[:reward].presence || "1"
  end

  def my_vote_questionnaire_ids
    Member.voted_polls.select{|e| e["poll_series_id"] != 0 }.collect{|e| e["poll_id"] }
  end

  def your_friend_ids
    # @friend_ids ||= @member.cached_get_friend_active.map(&:id)
    @friend_ids ||= Member.list_friend_active.map(&:id)
  end

  def your_following_ids
    # @following_ids ||= @member.cached_get_following.map(&:id)
    @following_ids ||= Member.list_friend_following.map(&:id)
  end

  def poll_overall
    @overall_timeline ||= split_poll_and_filter
  end

  def total_entries
    cached_poll_ids_of_poll_member.count
  end

  def get_poll_shared
    find_poll_share
  end

  def get_overall_poll
    overall_timeline
  end

  def unvote_count
    poll_id_from_poll_member = PollMember.available.where("id IN (?)", cached_poll_ids_of_poll_member).map(&:poll_id)
    (poll_id_from_poll_member - Member.voted_polls.collect{|e| e["poll_id"] }).count
  end

  private

  def find_poll_me_and_friend_and_group_and_public
    poll_member_query = "poll_members.member_id = ? AND #{poll_non_share_non_in_group}"

    poll_friend_query = "poll_members.member_id IN (?) AND polls.public = 'f' AND #{poll_non_share_non_in_group}"

    poll_group_query = "poll_members.poll_id IN (?) AND poll_members.in_group = 't' AND poll_members.share_poll_of_id = 0"

    poll_series_group_query = "poll_members.series = 't' AND poll_members.in_group = 't' AND poll_members.poll_series_id IN (?)"

    poll_my_vote = "poll_members.poll_id IN (?) AND poll_members.share_poll_of_id = 0"

    poll_public_query = filter_public.eql?("1") ? "(poll_members.public = 't' AND #{poll_non_share_non_in_group}) OR (polls.campaign_id != 0 AND #{poll_non_share_non_in_group})" : "NULL"

    new_your_friend_ids = filter_friend_following.eql?("1") ? ((your_friend_ids | your_following_ids) << member_id) : [0]

    new_find_poll_in_my_group = filter_group.eql?("1") ? find_poll_in_my_group : [0]

    new_find_poll_series_in_group = filter_group.eql?("1") ? find_poll_series_in_group : [0]

    query = PollMember.available.unexpire.joins(:poll).where("(#{poll_friend_query})" \
                                                             "OR (#{poll_group_query})" \
                                                             "OR (#{poll_series_group_query})" \
                                                             "OR (#{poll_public_query})",
                                                             # "OR (#{poll_reward_query} AND #{poll_unexpire})",
                                                             new_your_friend_ids,
                                                             new_find_poll_in_my_group, new_find_poll_series_in_group)

    query = query.limit(LIMIT_TIMELINE)

    ids, poll_ids = query.map(&:id), query.map(&:poll_id)
  end

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  def poll_non_share_non_in_group
    "poll_members.in_group = 'f' AND poll_members.share_poll_of_id = 0"
  end

  def find_poll_in_my_group
    PollGroup.where("group_id IN (?)", your_group_ids).limit(LIMIT_TIMELINE).map(&:poll_id).uniq
  end

  def find_poll_series_in_group
    PollSeriesGroup.where("group_id IN (?)", your_group_ids).limit(LIMIT_TIMELINE).map(&:poll_series_id).uniq
  end

  def find_poll_share
    query_poll_shared = "poll_members.member_id IN (?) AND poll_members.share_poll_of_id <> 0"

    new_your_friend_ids = filter_public.eql?("1") ? your_friend_ids : [0]
    your_following_ids = filter_public.eql?("1") ? your_following_ids : [0]

    query = PollMember.available.unexpire.joins(:poll).where("(#{query_poll_shared})" \
                                                    "OR (#{query_poll_shared})",
                                                    new_your_friend_ids,
                                                    your_following_ids).limit(LIMIT_TIMELINE)

    query.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end


  def check_new_pull_request(query)
    if to_bool(@pull_request)
      query = query.joins(:poll).where("polls.updated_at > ? AND polls.id > ?", @member.poll_overall_req_at, since_id)
    end
    query
  end

  def overall_timeline
    ids, poll_ids = find_poll_me_and_friend_and_group_and_public
    shared = find_poll_share
    poll_member_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
    poll_member_ids_sort - check_poll_not_show_result - hidden_poll - my_vote_questionnaire_ids
  end

  def cached_poll_ids_of_poll_member
    @cache_poll_ids ||= Rails.cache.fetch([ 'overall_timeline', member_id]) do
      overall_timeline
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
      Rails.cache.delete(['overall_timeline', member_id ])
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

  def check_poll_not_show_result
    Member.voted_polls.collect{|e| e["poll_id"] if e["show_result"] == false }.compact
  end

  def poll_shared_at(poll_member)
    if poll_member.in_group
      Hash["in" => "Group", "group_detail" => serailize_group_detail_as_json(poll_member.share_poll_of_id) ]
    else
      PollType.to_hash(PollType::WHERE[:friend_following])
    end
  end

  def count_feeded_load(poll)
    poll.update_columns(loadedfeed_count: poll.loadedfeed_count + 1) if (poll.member_type == "Company" || poll.member_type == "Brand")
  end

  def serailize_group_detail_as_json(poll_id)
    group = PollGroup.where(poll_id: poll_id).pluck(:group_id)
    group_list = group & your_group_ids

    if group.present?
      ActiveModel::ArraySerializer.new(Group.where("id IN (?)", group_list), each_serializer: GroupSerializer).as_json
    else
      nil
    end
  end

  def to_bool(request)
    return true   if request == "true"
    return false  if request == "false"
  end

  def serailize_member_detail_as_json(member_of_share)
    ActiveModel::ArraySerializer.new(member_of_share, serializer_options: { current_member: @member }, each_serializer: MemberSharedDetailSerializer).as_json
  end

end
