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
  
  def process_promote
    if member.citizen?
      member.with_lock do
        member.point -= 1
        member.save!
      end
    end

    HistoryPromotePoll.create!(member: member, poll: poll)
    poll.update!(public: true)
    poll
  end

  def process_bookmark
    Bookmark.create!(member_id: member.id, bookmarkable_id: poll.id)
    clear_bookmark_cached_for_member
    poll
  end

  def process_unbookmark
    bookmark = Bookmark.find_by(member_id: member.id, bookmarkable_id: poll.id)
    bookmark.destroy

    clear_bookmark_cached_for_member
    poll
  end

  def clear_history_viewed_cached_for_member
    FlushCached::Member.new(member).clear_list_history_viewed_polls
  end

  def clear_bookmark_cached_for_member
    FlushCached::Member.new(member).clear_list_bookmark_polls
  end

end