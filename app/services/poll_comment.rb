class PollComment 
  def initialize(poll, member, comment_message)
    @poll = poll
    @member = member
    @comment_message = comment_message
  end

  def commenting
    return false unless @poll.allow_comment


    comment = Comment.new(poll_id: @poll.id, member_id: @member.id, message: @comment_message)

    comment_saved_success = comment.save
    if comment_saved_success
        @poll.with_lock do 
            @poll.comment_count += 1
            @poll.save!
        end
    end

    return comment_saved_success
  end
end