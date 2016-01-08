module Member::Private::PollAction

  private
  
  def poll_inquiry_service
    @poll_inquiry_service ||= Member::PollInquiry.new(member, poll)
  end

  def create_poll_viewing_record
    return if HistoryView.exists?(member_id: member.id, poll_id: poll.id)
    
    create_history_view_for_member
    
    clear_history_viewed_cached_for_member
  end

  def create_history_view_for_member
    HistoryView.transaction do
      HistoryView.create! member_id: member.id, poll_id: poll.id
      create_company_group_action_tracking_record_for_action('view')

      poll.with_lock do
        poll.view_all += 1
        poll.save!
      end
    end
  end

  def create_company_group_action_tracking_record_for_action(action)
    return unless poll.in_group

    group_ids = poll.in_group_ids.split(',').map(&:to_i)
    group_ids.each do |group_id|
      member.activity_feeds.create! action: action, trackable: poll, group_id: group_id
    end
  end

  def process_close
    poll.update!(close_status: true)
    poll
  end

  def process_vote
    increase_vote_count
    create_company_group_action_tracking_record_for_action('vote')
    create_history_vote
    delete_saved_poll
    trigger_vote

    claer_voted_cached_for_member
    clear_voting_poll_cached_for_member
    send_vote_notification

    predict_campaign

    poll
  end

  def choice
    Choice.cached_find(vote_params[:choice_id])
  end

  def increase_vote_count
    choice.with_lock do
      choice.vote += 1
      choice.save!  
    end

    poll.with_lock do
      poll.vote_all += 1
      poll.save!
    end
  end

  def create_history_vote
    HistoryVote.create!(member_id: member.id, poll_id: poll.id, choice_id: choice.id \
      , poll_series_id: poll_series_id, data_analysis: vote_params[:data_analysis], surveyor_id: vote_params[:surveyor_id] \
      , created_at: Time.zone.now + 0.5.seconds, show_result: show_result)
  end

  def poll_series_id
    poll.series ? poll.poll_series_id : 0
  end
  
  def show_result
    !vote_params[:anonymous]
  end

  def trigger_vote
    Trigger::Vote.new(member, poll, choice).trigger!
  end

  def predict_campaign
    return unless poll.get_campaign
    poll.find_campaign_for_predict?(member)
  end

  def process_bookmark
    Bookmark.create!(member_id: member.id, bookmarkable: poll)
    clear_bookmarked_cached_for_member
    poll
  end

  def process_unbookmark
    bookmarked_poll = Bookmark.find_by(member_id: member.id, bookmarkable_id: poll.id)
    return unless bookmarked_poll.present?
    bookmarked_poll.destroy

    clear_bookmarked_cached_for_member
    poll
  end

  def process_save
    SavePollLater.create!(member_id: member.id, savable: poll)

    clear_saved_cached_for_member
    poll
  end

  def process_watch
    watched_poll = member.watcheds.find_by(poll_id: poll.id)

    if watched_poll.present?
      watched_poll.update!(poll_notify: true, comment_notify: true)
    else
      member.watcheds.create!(poll: poll, poll_notify: true, comment_notify: true)
    end

    clear_watched_cached_for_member
    poll
  end

  def process_unwatch
    watched_poll = member.watcheds.find_by(poll_id: poll.id)
    return unless watched_poll.present?
    watched_poll.update!(poll_notify: false, comment_notify: false)

    clear_watched_cached_for_member
    poll
  end

  def process_not_interest
    NotInterestedPoll.create!(member_id: member.id, unseeable: poll)
    NotifyLog.deleted_with_poll_and_member(poll, member)

    process_unbookmark
    delete_saved_poll
    process_unwatch

    poll
  end

  def delete_saved_poll
    saved_poll = SavePollLater.find_by(member_id: member.id, savable: poll)
    return unless saved_poll.present?
    saved_poll.destroy
    clear_saved_cached_for_member
  end

  def process_promote
    if member.citizen?
      member.with_lock do
        member.point -= 1
        member.save!
      end
    end

    HistoryPromotePoll.create!(member_id: member.id, poll: poll)
    poll.update!(public: true)
    poll
  end

  def process_report
    MemberReportPoll.create!(member_id: member.id, poll_id: poll.id \
      , message: report_params[:message], message_preset: report_params[:message_preset])
    reporting

    NotifyLog.deleted_with_poll_and_member(poll, member)

    claer_voted_cached_for_member
    clear_reported_cached_for_member
    
    send_report_notification if poll.in_group

    poll
  end

  def reporting
    poll.with_lock do
      poll.report_count += member.report_power
      poll.save!
    end

    process_unbookmark
    delete_saved_poll
    process_unwatch

    return unless poll.report_count >= 10
    poll.update!(status_poll: :black)
  end

  def clear_history_viewed_cached_for_member
    FlushCached::Member.new(member).clear_list_history_viewed_polls
  end

  def claer_created_cached_for_member
    FlushCached::Member.new(member).clear_list_created_polls
  end

  def claer_voted_cached_for_member
    FlushCached::Member.new(member).clear_list_voted_polls
  end

  def clear_bookmarked_cached_for_member
    FlushCached::Member.new(member).clear_list_bookmarked_polls
  end

  def clear_saved_cached_for_member
    FlushCached::Member.new(member).clear_list_saved_polls
  end

  def clear_watched_cached_for_member
    FlushCached::Member.new(member).clear_list_watched_polls
  end

  def clear_reported_cached_for_member
    FlushCached::Member.new(member).clear_list_report_polls
  end

  def clear_voting_poll_cached_for_member
    FlushCached::Member.new(member, poll).clear_voting_poll_id
  end

  def send_report_notification
    ReportPollWorker.perform_async(member.id, poll.id) unless Rails.env.test?
  end

  def send_vote_notification
    return if poll.series || owner_poll
    sum_vote_notification
    Poll::VoteNotifyLog.new(member, poll, show_result).create!
  end

  def sum_vote_notification
    return unless poll.notify_state.idle?
    poll.update!(notify_state: 1)
    poll.update!(notify_state_at: Time.zone.now)
    SumVotePollWorker.perform_in(1.minutes, poll.id) unless Rails.env.test?
  end
end