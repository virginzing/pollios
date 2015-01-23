class V6::OverallTimeline
  include GroupApi
  include Timelinable

  TYPE_TIMELINE = 'overall_timeline'

  attr_accessor :list_polls, :list_shared, :order_ids, :next_cursor

  def initialize(member, options)
    @member = member
    @options = options
    @next_cursor = 0
    @list_polls = []
    @list_shared = []
    @order_ids = []
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

  def find_poll_me_and_friend_and_group_and_public
    poll_priority = []
    created_time = []

    poll_member_query = "poll_members.member_id = ? AND #{poll_non_share_non_in_group}"

    poll_friend_query = "poll_members.member_id IN (?) AND polls.public = 'f' AND #{poll_non_share_non_in_group}"

    # poll_group_query = "poll_members.poll_id IN (?) AND poll_members.in_group = 't' AND poll_members.share_poll_of_id = 0"

    poll_group_query = "poll_groups.group_id IN (?) AND poll_groups.share_poll_of_id = 0"

    # poll_series_group_query = "poll_members.series = 't' AND poll_members.in_group = 't' AND poll_members.poll_series_id IN (?)"

    poll_series_group_query = "poll_groups.group_id IN (?) AND poll_groups.share_poll_of_id != 0"

    poll_my_vote = "poll_members.poll_id IN (?) AND poll_members.share_poll_of_id = 0"

    poll_public_query = filter_public.eql?("1") ? "(poll_members.public = 't' AND #{poll_non_share_non_in_group}) OR (polls.campaign_id != 0 AND #{poll_non_share_non_in_group})" : "NULL"

    new_your_friend_ids = filter_friend_following.eql?("1") ? ((your_friend_ids | your_following_ids) << member_id) : [0]

    # new_find_poll_in_my_group = filter_group.eql?("1") ? find_poll_in_my_group : [0]
    new_find_poll_in_my_group = filter_group.eql?("1") ? your_group_ids : [0]

    # new_find_poll_series_in_group = filter_group.eql?("1") ? find_poll_series_in_group : [0]

    new_find_poll_series_in_group = filter_group.eql?("1") ? your_group_ids : [0]

    query = PollMember.available.unexpire.joins(:poll).includes(:poll => [:poll_groups])
                                                      .where("(#{poll_friend_query})" \
                                                             "OR (#{poll_group_query})" \
                                                             "OR (#{poll_series_group_query})" \
                                                             "OR (#{poll_public_query})",
                                                             new_your_friend_ids,
                                                             new_find_poll_in_my_group, new_find_poll_series_in_group).references(:poll_groups)

    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0

    query = query.limit(LIMIT_TIMELINE)

    query.each do |q|
      poll_priority << q.poll.priority
      created_time << q.poll.created_at
    end

    ids, poll_ids, priority, created_time = query.map(&:id), query.map(&:poll_id), poll_priority, created_time
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
    
    query = query.where("polls.id NOT IN (?)", with_out_poll_ids) if with_out_poll_ids.count > 0
    query = query.where("polls.poll_series_id NOT IN (?)", with_out_questionnaire_id) if with_out_questionnaire_id.count > 0
    
    query.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end

  def main_timeline # must have (ex. [1,2,3,4] poll_member's ids)  # ids is timeline_id or poll_member_id
    ids, poll_ids, priority, created_time = find_poll_me_and_friend_and_group_and_public


    # shared = find_poll_share
    # poll_member_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
    # poll_member_ids_sort

    # p "ids => #{ids}"
    # p "priority => #{priority}"
    # p "poll_ids => #{poll_ids}"

    ids = FeedAlgorithm.new(ids, poll_ids, priority, created_time).sort_by_priority

    ids
    # ids.sort!{|x,y| y <=> x }
  end

  def poll_shared_at(poll_member)
    if poll_member.in_group
      Hash["in" => "Group", "group_detail" => serailize_group_detail_as_json(poll_member.share_poll_of_id) ]
    else
      PollType.to_hash(PollType::WHERE[:friend_following])
    end
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

  def serailize_member_detail_as_json(member_of_share)
    ActiveModel::ArraySerializer.new(member_of_share, serializer_options: { current_member: @member }, each_serializer: MemberSharedDetailSerializer).as_json
  end
end
