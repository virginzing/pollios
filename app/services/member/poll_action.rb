class Member::PollAction

  include Member::Private::PollActionGuard
  include Member::Private::PollAction

  attr_reader :member, :poll, :poll_params, :vote_params, :report_params, :comment_params, :pending_vote

  def initialize(member, poll = nil, options = {})
    @member = member
    @poll = poll
    @options = options
  end

  def view
    create_poll_viewing_record
  end

  def create(params)
    @poll_params = params
    can_create, message = can_create?
    fail ExceptionHandler::UnprocessableEntity, message unless can_create

    process_create
  end

  def close
    can_close, message = can_close?
    fail ExceptionHandler::UnprocessableEntity, message unless can_close

    process_close
  end

  def vote(params)
    @vote_params = params
    can_vote, condition = can_vote?
    message = condition.is_a?(Hash) ? condition[:message] : condition

    fail ExceptionHandler::UnprocessableEntity, message unless can_vote

    condition.nil? ? process_vote : process_pending_vote(condition)
  end

  # TODO : move this to service trigger
  def trigger_pending_vote
    @vote_params = @pending_vote = PendingVote.find_by(member_id: member.id, poll_id: poll.id)

    return unless pending_vote.present?

    process_trigger_pending_vote
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

  def report(params)
    @report_params = params
    can_report, message = can_report?
    fail ExceptionHandler::UnprocessableEntity, message unless can_report

    process_report
  end

  def delete
    can_delete, message = can_delete?
    fail ExceptionHandler::UnprocessableEntity, message unless can_delete

    process_delete
  end

  def comment(params)
    @comment_params = params
    can_comment, message = can_comment?
    fail ExceptionHandler::UnprocessableEntity, message unless can_comment

    process_comment
  end

  def report_comment(params)
    @comment_params = params
    can_report_comment, message = can_report_comment?
    fail ExceptionHandler::UnprocessableEntity, message unless can_report_comment

    process_report_comment
  end

  def delete_comment(params)
    @comment_params = params
    can_delete_comment, message = can_delete_comment?
    fail ExceptionHandler::UnprocessableEntity, message unless can_delete_comment

    process_delete_comment
  end
end