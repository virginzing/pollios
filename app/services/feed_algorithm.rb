class FeedAlgorithm
  include ActionView::Helpers::DateHelper

  DAY_COMPARE = 100
  HIGH_VOTE_PRIORITY = 100
  VALUE_POLL_VOTED = 50
  VALUE_POLL_NOT_VOTE = 0


  def initialize(poll_member_ids, poll_ids, priority_poll_member_ids, created_time, updated_time)
    @poll_member_ids = poll_member_ids
    @poll_ids = poll_ids
    @priority_poll_member_ids = priority_poll_member_ids
    @vote_poll_ids = Member.voted_polls.collect{|e| e["poll_id"] }
    @created_time = created_time
    @updated_time = updated_time
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
        if e[:updated_time] > 10.minutes.ago
          e[:priority] = HIGH_VOTE_PRIORITY
        else
          e[:priority] = (e[:priority] - VALUE_POLL_VOTED) * time_ago_value(e[:created_at])
        end

        new_check_with_voted << e
      else
        e[:priority] = (e[:priority]) * time_ago_value(e[:created_at])
        new_check_with_voted << e 
      end    
    end

    new_check_with_voted
  end

  def time_ago_value(created_at)
    (DAY_COMPARE - (Time.zone.now.to_date - created_at.to_date).to_i) / 100.00
  end

  def sort_by_priority
    # check_with_voted.sort {|x,y| [y[:priority] <=> x[:priority]] }
    sort_by_and_reverse = check_with_voted.sort_by {|x| [x[:priority], x[:created_at]] }.reverse!
    sort_by_and_reverse.collect{|e| e[:poll_member_id] }
  end

end