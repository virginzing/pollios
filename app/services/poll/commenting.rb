class Poll::Commenting

  def initialize(poll, member, comment_message)
    @poll = poll
    @member = member
    @comment_message = comment_message

    @member_id = @member.id
    @poll_member_id = @poll.member_id
  end

  def commenting
    return false unless @poll.allow_comment

    comment = Comment.new(poll_id: @poll.id, member_id: @member.id, message: @comment_message)

    comment_saved_success = comment.save

    if comment_saved_success
      increase_poll_comment_count
    end

    return comment_saved_success
  end

  private

  def increase_poll_comment_count
    @poll.with_lock do 
      @poll.comment_count += 1
      @poll.save!
    end
  end

end