class Poll::CommentList

  attr_reader :poll, :viewing_member, :index

  def initialize(poll, options = {})
    @poll = poll

    @viewing_member = options[:viewing_member]
    @index = options[:index] || 1

    can_view, message = can_view?
    fail ExceptionHandler::UnprocessableEntity, message unless can_view
  end

  def can_view?
    return [true, nil] unless viewing_member
    can_view, message = poll_inquiry_service.can_view?
    return [false, message] unless can_view
    return [false, "You aren't vote this poll. Vote to see comments."] if not_voted_and_poll_not_closed

    [true, nil]
  end

  def comments
    comment_visibility
  end

  def comments_by_page
    comment_visibility.paginate(page: index)
  end

  def sort_comments_by_page
    comments_by_page.sort_by(&:created_at)
  end

  def next_index
    comments_by_page.next_page || 0
  end

  def comment_count
    comments.count
  end

  private

  def all_comment
    poll.comments.without_ban.without_deleted.order('comments.created_at DESC')
  end

  def comment_visibility
    return all_comment unless viewing_member
    all_comment.viewing_by_member(viewing_member)
  end

  def poll_inquiry_service
    Member::PollInquiry.new(viewing_member, poll)
  end

  def not_voted_and_poll_not_closed
    !poll_inquiry_service.voted? && !poll.close_status
  end

end