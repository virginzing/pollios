module Poll::Private::CommentList

  private

  def can_view?
    return [true, nil] unless viewing_member

    can_comment, message = poll_inquiry_service.can_comment?
    return [false, message] unless can_comment

    [true, nil]
  end

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
end