class Member::PollList
  
  def initialize(member)
    @member = member
  end

  def reports
    @report ||= cached_report_polls
  end

  def history_viewed
    @history_viewed ||= cached_history_viewed_polls
  end

  def voted_all
    @voted_all ||= cached_voted_all_polls
  end

  def watched_poll_ids
    @watches ||= cached_watch_polls
  end

  def report_comments
    @report_comments ||= cached_report_comments
  end

  def voted_poll?(poll)
    voted_all.collect{|e| e["poll_id"] }.include?(poll.id)    
  end

  def saved_poll_ids
    saved_later_query("Poll")
  end

  def saved_questionnaire_ids
    saved_later_query("PollSeries")
  end

  def not_interested_poll_ids
    not_interested_query("Poll")
  end

  def not_interested_questionnaire_ids
    not_interested_query("PollSeries")
  end

######### PRIVATE METHODS #########
  private

  def member_report_polls
    @member.poll_reports.to_a
  end
  
  def cached_report_polls
    Rails.cache.fetch("member/#{@member.id}/report_polls") { member_report_polls }
  end

  def member_report_commments
    @member.comment_reports.to_a  
  end

  def cached_report_comments
    Rails.cache.fetch("member/#{@member.id}/report_comments") { member_report_commments }
  end

  def member_history_viewed_polls
    @member.history_views.map(&:poll_id)
  end

  def member_watched_polls
    @member.watcheds.where(poll_notify: true, comment_notify: true)
  end

  def cached_history_viewed_polls
    Rails.cache.fetch("member/#{@member.id}/history_viewed_polls") { member_history_viewed_polls }
  end

  def member_voted_all_polls
    Poll.joins(:history_votes => :choice)
        .select("polls.*, history_votes.choice_id as choice_id")
        .where("(history_votes.member_id = #{@member.id} AND history_votes.poll_series_id = 0) " \
               "OR (history_votes.member_id = #{@member.id} AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)")
        .collect! { |poll| Hash["poll_id" => poll.id, "choice_id" => poll.choice_id, "poll_series_id" => poll.poll_series_id, "show_result" => poll.show_result, "system_poll" => poll.system_poll ] }.to_a

  end

  def cached_voted_all_polls
    Rails.cache.fetch("member/#{@member.id}/voted_all_polls") { member_voted_all_polls }
  end

  def cached_watch_polls
    Rails.cache.fetch("member/#{@member.id}/watch_polls") { member_watched_polls.map(&:poll_id) }
  end

  def saved_later_query(type_name)
    @member.save_poll_laters.where(savable_type: type_name).map(&:savable_id)
  end

  def not_interested_query(type_name)
    @member.not_interested_polls.where(unseeable_type: type_name).map(&:unseeable_id)
  end

end