class Member::PollList
  include Member::Private::PollList

  attr_reader :member, :viewing_member
  
  def initialize(member, options = {})
    @member = @viewing_member = member

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]
  end

  def reports
    cached_report_polls
  end

  def reports_ids
    reports.map(&:id)
  end

  def history_viewed
    cached_history_viewed_polls
  end

  def voted_all
    cached_voted_all_polls
  end

  def watched_poll_ids
    cached_watch_polls
  end

  def report_comments
    cached_report_comments
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

  def created
    all_created
  end

  def closed
    cached_all_closed
  end

  def viewed
    cached_history_viewed_polls  
  end

  def voted
    cached_all_voted
  end

  def bookmarks
    cached_all_bookmarked
  end

  def saved
    cached_all_saved_vote_later
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

  def cached_all_closed
    Rails.cache.fetch("members/#{member.id}/polls/closed") { all_closed }
  end

  def cached_all_voted
    Rails.cache.fetch("members/#{member.id}/polls/voted") { all_voted }
  end

  def cached_all_bookmarked
    Rails.cache.fetch("members/#{member.id}/polls/bookmarks") { all_bookmarked }
  end

  def cached_all_saved_vote_later
    Rails.cache.fetch("members/#{member.id}/polls/saved") { all_saved_vote_later }
  end
end