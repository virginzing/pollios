class PollCommenting
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
        @poll.with_lock do 
            @poll.comment_count += 1
            @poll.save!
        end
    end

    return comment_saved_success
  end

  # TODO: Make a "AllowComment Service" class for dealing with enabling, disabling attributes
  #
  # def disable_comment
  #   return false unless member_own_poll
  #   @poll.allow_comment = false
  #   return true
  # end

  # def enable_comment
  #   return false unless member_own_poll
  #   @poll.allow_comment = true
  # end

  # private
  # def member_own_poll
  #   return @poll_member_id == @member_id
  # end
end