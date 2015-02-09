class FeedAlgorithm
  include ActionView::Helpers::DateHelper
  include FeedSetting

  def initialize(poll_member_ids, poll_ids, priority_poll_member_ids, created_time, updated_time)
    @poll_member_ids = poll_member_ids
    @poll_ids = poll_ids
    @priority_poll_member_ids = priority_poll_member_ids
    @vote_poll_ids = Member.voted_polls.collect{|e| e["poll_id"] }
    @created_time = created_time
    @updated_time = updated_time
    @filter_timeline_ids = []
  end

  def check_voted
    @check_voted ||= check_with_voted
  end

  def sort_by_priority
    sort_by_and_reverse = check_voted.sort_by {|x| [x[:priority], x[:created_at]] }.reverse!
    sort_by_and_reverse.collect{|e| e[:poll_member_id] }
  end

  def hash_priority
    check_voted.inject({}) {|h, v| h[ v[:poll_member_id] ] = v[:priority]; h}
  end

  private

  def merge_poll_member_with_poll_id # poll_id, poll_member_id, priority 
    @poll_ids.each_with_index do |poll_id, index|
      @filter_timeline_ids << { poll_id: poll_id, poll_member_id: @poll_member_ids[index], priority: @priority_poll_member_ids[index], created_at: @created_time[index], updated_at: @updated_time[index] }
    end
    # puts "filter timtline ids => #{@filter_timeline_ids}"
    @filter_timeline_ids
  end

  def check_with_voted
    new_check_with_voted = []

    merge_poll_member_with_poll_id.each_with_index do |e, index|
      feed = e[:priority]

      if @vote_poll_ids.include?(e[:poll_id]) ## voted
        
        if e[:updated_at] > 2.days.ago
          e[:priority] = time_ago_value(e[:created_at]) * (feed + FeedSetting::VOTED + FeedSetting::UPDATED_POLL)
        else
          e[:priority] = time_ago_value(e[:created_at]) * (feed + FeedSetting::VOTED)
        end
      else
        if e[:created_at] > 20.minutes.ago
          e[:priority] = time_ago_value(e[:created_at]) * (feed + FeedSetting::NOT_YET_VOTE + FeedSetting::CREATED_RECENT) 
        else
          e[:priority] = time_ago_value(e[:created_at]) * (feed + FeedSetting::NOT_YET_VOTE) 
        end
      end

      new_check_with_voted << e     
    end
    # puts "new_check_with_voted => #{new_check_with_voted}"
    new_check_with_voted
  end


  def time_ago_value(created_at)
    time_compare = FeedSetting::DAY_COMPARE - (Time.zone.now.to_date - created_at.to_date).to_i
    time_compare <= 0 ? 0 : time_compare    
  end

end