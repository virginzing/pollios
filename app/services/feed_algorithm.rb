class FeedAlgorithm

  VALUE_POLL_VOTED = 50
  VALUE_POLL_NOT_VOTE = 0


  def initialize(poll_member_ids, poll_ids, priority_poll_member_ids, created_time)
    @poll_member_ids = poll_member_ids
    @poll_ids = poll_ids
    @priority_poll_member_ids = priority_poll_member_ids
    @vote_poll_ids = Member.voted_polls.collect{|e| e["poll_id"] }
    @created_time = created_time
    @filter_timeline_ids = []
  end

  def merge_poll_member_with_poll_id # poll_id, poll_member_id, priority 
    @poll_ids.each_with_index do |poll_id, index|
      @filter_timeline_ids << { poll_id: poll_id, poll_member_id: @poll_member_ids[index], priority: @priority_poll_member_ids[index], created_at: @created_time[index] }
    end
    # puts "filter timtline ids => #{@filter_timeline_ids}"
    @filter_timeline_ids
  end

  def check_with_voted
    new_check_with_voted = []

    merge_poll_member_with_poll_id.each_with_index do |e, index|
      if @vote_poll_ids.include?(e[:poll_id])
        e[:priority] = (e[:priority] - VALUE_POLL_VOTED)
        new_check_with_voted << e
      else
        new_check_with_voted << e 
      end    
    end

    new_check_with_voted
  end

  def sort_by_priority
    # check_with_voted.sort {|x,y| [y[:priority] <=> x[:priority]] }
    sort_by_and_reverse = check_with_voted.sort_by {|x| [x[:priority], x[:created_at]] }.reverse!
    sort_by_and_reverse.collect{|e| e[:poll_member_id] }
  end

end