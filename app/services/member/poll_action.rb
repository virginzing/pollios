class Member::PollAction

  attr_reader :member, :poll

  def initialize(member, poll = nil, options = {})
    @member = member
    @poll = poll
    @options = options
  end

  def view
    create_poll_viewing_record
  end

  private

  def create_poll_viewing_record
    return if HistoryView.exists?(member_id: member.id, poll_id: poll.id)
    
    create_history_view_for_member
    FlushCached::Member.new(member).clear_list_history_viewed_polls
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

  def create
    can_create, message = can_create?
    fail ExceptionHandler::UnprocessableEntity, message unless can_create
      
    process_create
  end

  def close
    can_close, message = can_close?
    fail ExceptionHandler::UnprocessableEntity, message unless can_close
      
    process_close
  end

  def vote
    can_vote, message = can_vote?
    fail ExceptionHandler::UnprocessableEntity, message unless can_vote

    process_vote
  end

  def bookmark
    can_bookmark, message = can_bookmark?
    fail ExceptionHandler::UnprocessableEntity, message unless can_bookmark

    process_bookmark
  end

  def unbookmark
    can_unbookmark, message = can_unbookmark?
    fail ExceptionHandler::UnprocessableEntity, message unless can_unbookmark

    process_unbookmark
  end

  def save
    can_save, message = can_save?
    fail ExceptionHandler::UnprocessableEntity, message unless can_save

    process_save
  end

  def watch
    can_watch, message = can_watch?
    fail ExceptionHandler::UnprocessableEntity, message unless can_watch

    process_watch
  end

  def unwatch
    can_unwatch, message = can_unwatch?
    fail ExceptionHandler::UnprocessableEntity, message unless can_unwatch

    process_unwatch
  end

  def not_interest
    can_not_interest, message = can_not_interest?
    fail ExceptionHandler::UnprocessableEntity, message unless can_not_interest

    process_not_interest
  end

  def promote
    can_promote, message = can_promote?
    fail ExceptionHandler::UnprocessableEntity, message unless can_promote

    process_promote
  end

  def report
    can_report, message = can_report?
    fail ExceptionHandler::UnprocessableEntity, message unless can_report

    process_report
  end

  def comment
    can_comment, message = can_comment?
    fail ExceptionHandler::UnprocessableEntity, message unless can_comment

    process_comment
  end

end