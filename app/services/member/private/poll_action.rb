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

  def clear_history_viewed_cached_for_member
    FlushCached::Member.new(member).clear_list_history_viewed_polls
  end

end