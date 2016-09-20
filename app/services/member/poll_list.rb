class Member::PollList
  include Member::Private::PollList

  attr_reader :member, :viewing_member, :index
  
  def initialize(member, options = {})
    @member = @viewing_member = member

    @viewing_member = options[:viewing_member] if options[:viewing_member]
    @index = options[:index] || 1
  end

  def member_states_ids
    {
      reported_ids: ids_for(reports),
      bookmarked_ids: ids_for(bookmarks),
      saved_ids: ids_for(saved),
      watching_ids: watched_poll_ids,
      voted_ids: voted_all.collect { |poll| poll[:poll_id] }
    }
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
    all_voted
  end

  def bookmarks
    cached_all_bookmarked
  end

  def saved
    cached_all_saved_vote_later
  end

  def polls_by_page(list)
    list.paginate(page: index)
  end
  
  def next_index(list)
    next_page_index(list)
  end

  def recent_public_activity(limit)
    public_activity(limit)
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