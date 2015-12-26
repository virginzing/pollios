module Timelinable

  LIMIT_TIMELINE = 500
  LIMIT_POLL = 30

  def member_id
    @member.id
  end

  def member_poll_list
    @member_poll_list ||= Member::PollList.new(@member)
  end

  # def init_un_see_poll
  #   @init_un_see_poll ||= UnseePoll.new({ member_id: member_id})
  # end

  def not_interested_poll_ids
    # init_un_see_poll.get_list_poll_id
    member_poll_list.not_interested_poll_ids
  end

  def not_interested_questionnaire_ids
    # init_un_see_poll.get_list_questionnaire_id
    member_poll_list.not_interested_questionnaire_ids
  end

  def saved_poll_ids_later
    member_poll_list.saved_poll_ids
  end

  def saved_questionnaire_ids_later
    member_poll_list.saved_questionnaire_ids
  end

  def vote_all_polls
    # @vote_all_polls ||= Member.voted_polls.collect {|e| e["poll_id"] }
    @vote_all_polls ||= member_poll_list.voted_all.collect {|e| e[:poll_id] }
  end

  def my_vote_questionnaire_ids
    # @my_vote_questionnaire_ids ||= Member.voted_polls.select{|e| e[:poll_series_id] != 0 }.collect{|e| e[:poll_id] }
    @my_vote_questionnaire_ids ||= member_poll_list.voted_all.select{|e| e[:poll_series_id] != 0 }.collect{|e| e[:poll_id] }
  end

  def history_vote_system_poll
    # Member.voted_polls.select{|e| e if e["system_poll"] }.collect{|e| e["poll_id"] }
    member_poll_list.voted_all.select{|e| e if e[:system_poll] }.collect{|e| e[:poll_id] }
  end

  def block_users
    Member::MemberList.new(@member).blocks.map(&:id)
  end

  # def check_poll_not_show_result
  #   Member.voted_polls.collect{|e| e["poll_id"] if e["show_result"] == false }.compact
  # end

  # Filter with out poll & questionnaire

  def with_out_poll_ids
    my_vote_questionnaire_ids | not_interested_poll_ids | saved_poll_ids_later | history_vote_system_poll
  end

  def with_out_questionnaire_id
    not_interested_questionnaire_ids | saved_questionnaire_ids_later
  end

  def with_out_member_ids
    block_users
  end

  # check priority #

  def check_feed_type(poll)
    if poll.public
      FeedSetting::PUBLIC_FEED
    else
      if poll.in_group
        FeedSetting::GROUP_FEED   
      else
        FeedSetting::FRIEND_FOLLOWING_FEED
      end
    end
  end

  def check_poll_priority(poll)
    if vote_all_polls.include?(poll.id)
      0
    else
      poll.priority
    end
  end


  # Feed #


  def cached_poll_ids_of_poll_member(type_timeline)
    @cache_poll_ids ||= Rails.cache.fetch([ type_timeline, member_id]) do
      main_timeline
    end
  end

  def split_poll_and_filter(type_timeline)
    next_cursor = @options["next_cursor"]

    if next_cursor.presence && next_cursor != "0"
      next_cursor = next_cursor.to_i
      @cache_polls ||= cached_poll_ids_of_poll_member(type_timeline)

      if next_cursor.in? @cache_polls
        index = @cache_polls.index(next_cursor)
        @poll_ids = @cache_polls[(index+1)..(LIMIT_POLL+index)]
      else
        @cache_polls.select!{ |e| e < next_cursor }
        @poll_ids = @cache_polls[0..(LIMIT_POLL-1)] 
      end
    else
      Rails.cache.delete([type_timeline, member_id ])
      @cache_polls ||= cached_poll_ids_of_poll_member(type_timeline)
      @poll_ids = @cache_polls[0..(LIMIT_POLL - 1)]
    end

    if @cache_polls.size > LIMIT_POLL
      if @poll_ids.size == LIMIT_POLL
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
    # puts "@poll_ids => #{@poll_ids}"
    # poll_member = PollMember.includes([{:poll => [:groups, :choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).order("id desc")
    poll_member = PollMember.includes([{:poll => [:groups, :choices, :campaign, :poll_series, :member]}]).where("id IN (?)", @poll_ids).sort_by { |p| @poll_ids.index(p.id) }

    # puts "poll_member => #{poll_member.map(&:id)}"

    poll_member.each do |poll_member|
      if poll_member.share_poll_of_id == 0
        not_shared = Hash["shared" => false]
        list_polls << poll_member.poll
        list_shared << not_shared
      else
        find_poll = Poll.find_by(id: poll_member.share_poll_of_id)
        find_member_share = Member.joins(:share_polls).where("share_polls.poll_id = #{poll_member.poll_id}")
        shared = Hash["shared" => true, "shared_by" => serialize_member_detail_as_json(find_member_share), "shared_at" => poll_shared_at(poll_member) ]

        list_polls << find_poll
        list_shared << shared
      end
      order_ids << poll_member.id
    end

    [list_polls, list_shared, order_ids, next_cursor]
  end

  def poll_shared_at(poll_member)
    if poll_member.in_group
      Hash["in" => "Group", "group_detail" => serailize_group_detail_as_json(poll_member.share_poll_of_id) ]
    else
      PollType.to_hash(PollType::WHERE[:friend_following])
    end
  end

end