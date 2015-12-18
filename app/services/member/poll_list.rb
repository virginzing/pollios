class Member::PollList

  attr_reader :member
  
  def initialize(member)
    @member = member
  end

  def reports
    @report ||= cached_report_polls
  end

  def history_viewed
    @history_viewed ||= cached_history_viewed_polls
  end

  def poll(poll_id)
    poll ||= Poll.cached_find(poll_id)

    is_visible, error_message = Poll::Listing.new(poll).is_visible_to_member_with_error(member)
    if is_visible
      Member::PollAction.new(member, poll).view
      return poll, nil
    else
      return nil, error_message
    end

  end

  def voted_all
    @voted_all ||= cached_voted_all_polls
  end

  def voting_detail(poll_id)
    voting = cached_voting_detail_for_poll(poll_id)

    if voting.empty?
      return Hash['voted' => false]
    else
      return Hash['voted' => true, 'choice_id' => voting.first.choice_id]
    end
  end

  def watched_poll_ids
    @watches ||= cached_watch_polls
  end

  def report_comments
    @report_comments ||= cached_report_comments
  end

  def voted_poll?(poll)
    voted_all.collect { |e| e['poll_id'] }.include?(poll.id)    
  end

  def saved_poll_ids
    saved_later_query('Poll')
  end

  def saved_questionnaire_ids
    saved_later_query('PollSeries')
  end

  def not_interested_poll_ids
    not_interested_query('Poll')
  end

  def not_interested_questionnaire_ids
    not_interested_query('PollSeries')
  end

  def bookmarkeds
    cached_all_bookmarked
  end

  def bookmarked?(poll)
    bookmarkeds.map(&:id).include?(poll.id)
  end

  # private

  def member_report_polls
    @member.poll_reports.to_a
  end
  
  def cached_report_polls
    Rails.cache.fetch("member/#{member.id}/report_polls") { member_report_polls }
  end

  def member_report_commments
    @member.comment_reports.to_a  
  end

  def cached_report_comments
    Rails.cache.fetch("member/#{member.id}/report_comments") { member_report_commments }
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
        .where("(history_votes.member_id = #{@member.id} " \
               "AND history_votes.poll_series_id = 0)" \
               "OR (history_votes.member_id = #{@member.id} " \
               "AND history_votes.poll_series_id != 0 AND polls.order_poll = 1)")
        .collect! { |poll| Hash["poll_id" => poll.id, 
                           "choice_id" => poll.choice_id, 
                           "poll_series_id" => poll.poll_series_id, 
                           "show_result" => poll.show_result, 
                           "system_poll" => poll.system_poll ] }.to_a

  end

  def all_bookmarked
    Poll.joins('inner join bookmarks on polls.id = bookmarks.bookmarkable_id')
      .where("bookmarks.member_id = #{member.id}")
  end

  def voting_detail_for_poll(poll_id)
    HistoryVote.member_voted_poll(member.id, poll_id).to_a
  end

  def cached_voting_detail_for_poll(poll_id)
    Rails.cache.fetch("member/#{member.id}/voting/#{poll_id}") { voting_detail_for_poll(poll_id) }
  end

  def cached_voted_all_polls
    Rails.cache.fetch("member/#{member.id}/voted_all_polls") { member_voted_all_polls }
  end

  def cached_watch_polls
    Rails.cache.fetch("member/#{member.id}/watch_polls") { member_watched_polls.map(&:poll_id) }
  end

  def cached_all_bookmarked
    Rails.cache.fetch("member/#{member.id}/polls/bookmarks") do
      all_bookmarked
    end
  end

  def saved_later_query(type_name)
    @member.save_poll_laters.where(savable_type: type_name).map(&:savable_id)
  end

  def not_interested_query(type_name)
    @member.not_interested_polls.where(unseeable_type: type_name).map(&:unseeable_id)
  end

end