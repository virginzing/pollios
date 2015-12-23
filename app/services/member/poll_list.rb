class Member::PollList
  include Member::Private::PollList

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

  def watched_poll_ids
    @watches ||= cached_watch_polls
  end

  def report_comments
    @report_comments ||= cached_report_comments
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

  def bookmarks
    cached_all_bookmarked
  end

  def bookmarks_ids
    bookmarks.map(&:id)
  end

  # private
  
  def cached_report_polls
    Rails.cache.fetch("member/#{member.id}/report_polls") { member_report_polls }
  end

  def cached_report_comments
    Rails.cache.fetch("member/#{member.id}/report_comments") { member_report_commments }
  end

  def cached_history_viewed_polls
    Rails.cache.fetch("member/#{member.id}/history_viewed_polls") { member_history_viewed_polls }
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

end