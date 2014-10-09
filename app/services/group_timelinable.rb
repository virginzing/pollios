class GroupTimelinable
  include GroupApi
  include LimitPoll

  attr_accessor :poll_series, :poll_nonseries, :series_shared, :nonseries_shared, :next_cursor

  def initialize(member, options)
    @member = member
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(@member.id)
    @type = options["type"] || "all"
    @poll_series = []
    @poll_nonseries = []
    @series_shared = []
    @nonseries_shared = []
  end

  def member_id
    @member.id
  end

  def since_id
    @options["since_id"] || 0
  end

  def group_polls
    @group_timeline ||= split_poll_and_filter
  end

  def total_entries
    cached_poll_ids_of_poll_group.count
  end


  # def group_poll
  #   @group_poll ||= group_of_poll
  # end

  def test_poll
    find_poll_in_my_group
  end


  private

  def poll_expire_have_vote
    "polls.expire_date < '#{Time.now}' AND polls.vote_all <> 0"
  end

  def poll_unexpire
    "polls.expire_date > '#{Time.now}'"
  end

  # def group_of_poll
  #   query_group_poll = "poll_groups.group_id IN (?)"

  #   query =  Poll.joins(:poll_groups).uniq.
  #                 includes(:member, :poll_series, :campaign).
  #                 where("(#{query_group_poll} AND #{poll_unexpire})", your_group_ids)
  # end

  def find_poll_in_my_group
    query_poll_in_group = "group_id IN (?) AND share_poll_of_id = 0"

    poll_group = PollGroup.joins(:poll).where("polls.expire_status = 'f'").where("(#{query_poll_in_group} AND #{poll_unexpire}) OR (#{query_poll_in_group} AND #{poll_expire_have_vote})", your_group_ids, your_group_ids).limit(LIMIT_TIMELINE)
    # puts "poll_group => #{poll_group.to_a.uniq_by {|e| e.poll_id } }"
    poll_group = poll_group.to_a.uniq {|poll| poll.poll_id }

    ids, poll_ids = poll_group.map(&:id), poll_group.map(&:poll_id)
  end

  def find_poll_share_in_group
    query_poll_shared_in_group = "poll_groups.group_id IN (?) AND share_poll_of_id <> 0"

    poll_group = PollGroup.joins(:poll).where("polls.expire_status = 'f'").where("#{query_poll_shared_in_group} AND #{poll_unexpire}", your_group_ids)

    poll_group.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end

  def group_timeline
    ids, poll_ids = find_poll_in_my_group
    shared = find_poll_share_in_group
    poll_group_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
  end

  def cached_poll_ids_of_poll_group
    @cache_poll_ids ||= Rails.cache.fetch([ ENV["GROUP_TIMELINE"], member_id]) do
      group_timeline
    end
  end

  def split_poll_and_filter
    next_cursor = @options["next_cursor"]

    if next_cursor.presence && next_cursor != "0"
      next_cursor = next_cursor.to_i
      cache_polls = cached_poll_ids_of_poll_group
      index = cache_polls.index(next_cursor)
      index = -1 if index.nil?
      @poll_ids = cache_polls[(index+1)..(LIMIT_POLL+index)]
    else
      Rails.cache.delete([ ENV["GROUP_TIMELINE"], member_id ])
      cache_polls = cached_poll_ids_of_poll_group
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

    filter_group_timeline(next_cursor)
  end

  def filter_group_timeline(next_cursor)

    poll_group = PollGroup.includes([{:poll => [:groups, :choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).order("id desc")

    poll_group.each do |poll_group|
      if poll_group.share_poll_of_id == 0
        not_shared = Hash["shared" => false]
        if poll_group.poll.series
          poll_series << poll_group.poll
          series_shared << not_shared
        else
          poll_nonseries << poll_group.poll
          nonseries_shared << not_shared
        end
      else
        find_poll = Poll.find_by(id: poll_group.share_poll_of_id)
        find_member_share = Member.joins(:share_polls).where("share_polls.poll_id = #{poll_group.poll_id} AND share_polls.shared_group_id = #{poll_group.group_id}")

        shared = Hash["shared" => true, "shared_by" => serailize_member_detail_as_json(find_member_share) , "shared_at" => poll_shared_at(poll_group) ]
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

  def poll_shared_at(poll_group)
    Hash["in" => "Group", "group_detail" => serailize_group_detail_as_json(poll_group.share_poll_of_id) ]
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
