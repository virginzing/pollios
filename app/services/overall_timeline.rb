class OverallTimeline

  LIMIT_TIMELINE = 3000
  LIMIT_POLL = 10

  attr_accessor :poll_series, :poll_nonseries, :series_shared, :nonseries_shared, :next_cursor

  def initialize(member_obj, options)
    @member = member_obj
    @options = options
    @hidden_poll = HiddenPoll.my_hidden_poll(member_obj.id)
    @your_group = member_obj.get_group_active
    @poll_series = []
    @poll_nonseries = []
    @series_shared = []
    @nonseries_shared = []
  end

  def member_id
    @member.id
  end

  def your_friend_ids
    @friend_ids ||= @member.whitish_friend.map(&:followed_id)
  end

  def your_group_ids
    @group_poll_ids ||= @your_group.pluck(:id)  
  end

  def group_by_name
    Hash[@your_group.map{ |f| [f.id, Hash["id" => f.id, "name" => f.name, "photo" => f.get_photo_group, "member_count" => f.member_count, "poll_count" => f.poll_count]] }]
  end

  def poll_overall
    @overall_timeline ||= split_poll_and_filter
  end

  private

  def find_poll_me_and_friend_and_group_and_public
    query = PollMember.where("(member_id = ? AND in_group = ? AND share_poll_of_id = 0) " \
        "OR (member_id IN (?) AND in_group = ? AND share_poll_of_id = 0) " \
        "OR (poll_id IN (?) AND in_group = ? AND share_poll_of_id = 0) " \
        "OR (public = ? AND in_group = ? AND share_poll_of_id = 0)", 
        member_id, false, 
        your_friend_ids, false, 
        find_poll_in_my_group, true, 
        true, false).limit(LIMIT_TIMELINE)

      poll_member = check_hidden_poll(query)
      ids, poll_ids = poll_member.map(&:id), poll_member.map(&:poll_id)
  end

  def find_poll_in_my_group
    query = PollGroup.where("group_id IN (?)", your_group_ids).limit(LIMIT_TIMELINE).map(&:poll_id)
  end

  def find_poll_share
    query = PollMember.where("member_id IN (?) AND share_poll_of_id != ?", your_friend_ids, 0).limit(LIMIT_TIMELINE)
    poll_member = check_hidden_poll(query)
    poll_member.collect{|poll| [poll.id, poll.share_poll_of_id]}.sort! {|x,y| y.first <=> x.first }.uniq {|s| s.last }
  end
  
  def check_hidden_poll(query)
    @hidden_poll.empty? ? query : query.hidden(@hidden_poll)
  end
  
  def overall_timeline
    ids, poll_ids = find_poll_me_and_friend_and_group_and_public
    shared = find_poll_share
    poll_member_ids_sort = (shared.delete_if {|id| id.first if poll_ids.include?(id.last) }.collect {|e| e.first } + ids).sort! { |x,y| y <=> x }
  end

  def cached_poll_ids_of_poll_member
    Rails.cache.fetch([ ENV["OVERALL_TIMELINE"], member_id]) do
      overall_timeline
    end
  end

  def split_poll_and_filter
    next_cursor = @options["next_cursor"]
    puts "next_cursor =>  #{next_cursor}"

    if next_cursor.presence && next_cursor != "0"
      next_cursor = next_cursor.to_i
      cache_polls = cached_poll_ids_of_poll_member
      index = cache_polls.index(next_cursor)
      index = -1 if index.nil?
      @poll_ids = cache_polls[(index+1)..(LIMIT_POLL+index)]
    else
      Rails.cache.delete([ ENV["OVERALL_TIMELINE"], member_id ])
      cache_polls = cached_poll_ids_of_poll_member
      @poll_ids   = cache_polls[0..(LIMIT_POLL - 1)]
    end

    puts "original cache : #{cache_polls}"
    puts "cache poll id : #{@poll_ids}"

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

    filter_overall_timeline(next_cursor)
  end



  def filter_overall_timeline(next_cursor)
    poll_member = PollMember.includes([{:poll => [:groups, :choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).order("id desc")

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