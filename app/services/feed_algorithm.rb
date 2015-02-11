class FeedAlgorithm
  include ActionView::Helpers::DateHelper
  include FeedSetting

  def initialize(poll_member_ids, poll_ids, feed, priority, created_time, updated_time)
    @poll_member_ids = poll_member_ids
    @poll_ids = poll_ids
    @feed = feed
    @priority = priority
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
      @filter_timeline_ids << { poll_id: poll_id, poll_member_id: @poll_member_ids[index], feed: @feed[index], priority: @priority[index], created_at: @created_time[index], updated_at: @updated_time[index] }
    end
    # puts "filter timtline ids => #{@filter_timeline_ids}"
    @filter_timeline_ids
  end

  def check_with_voted
    new_check_with_voted = []

    merge_poll_member_with_poll_id.each_with_index do |e, index|
      feed = e[:feed]

      vote_status = @vote_poll_ids.include?(e[:poll_id]) ? FeedSetting::VOTED : FeedSetting::NOT_YET_VOTE
      updated_2_days = (e[:updated_at] > 2.days.ago) ? FeedSetting::UPDATED_POLL : 0
      created_20_min = (e[:created_at] > 20.minutes.ago) ? FeedSetting::CREATED_RECENT : 0

      range_created_at = check_range_create_at(e[:created_at])

      poll_metadata_score = time_ago_value(e[:created_at]) * (feed + vote_status + updated_2_days + range_created_at)
      poll_value_score = e[:priority]

      e[:priority] = poll_value_score + poll_metadata_score

      new_check_with_voted << e     
    end

    new_check_with_voted
  end


  def time_ago_value(created_at)
    time_compare = FeedSetting::DAY_COMPARE - (Time.zone.now.to_date - created_at.to_date).to_i
    time_compare <= 0 ? 0 : time_compare    
  end

  def check_range_create_at(created_at)
    time_ago_minutes = ((Time.zone.now - created_at)/60.00).round

    if time_ago_minutes >= FeedSetting::RANGE_TIME_COMPARE
      0
    else
      ((FeedSetting::RANGE_TIME_COMPARE - time_ago_minutes) / 30.00).round
    end
  end

end