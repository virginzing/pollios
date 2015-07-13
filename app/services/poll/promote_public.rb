class Poll::PromotePublic
  def initialize(member, poll)
    @member = member
    @poll = poll
  end

  def validates!
    fail ExceptionHandler::UnprocessableEntity, "You're not poll owner" if @member.id != @poll.member_id
    fail ExceptionHandler::UnprocessableEntity, ExceptionHandler::Message::Member::POINT_ZERO if (@member.point == 0 && @member.citizen?)
  end

  def decrease_point!
    if @member.citizen?
      @member.with_lock do
        @member.point -= 1
        @member.save!
      end
    end
  end

  def log!
    HistoryPromotePoll.create!(member: @member, poll: @poll)
  end

  def promote!
    find_poll_members = @poll.poll_members

    if find_poll_members.present?
      log!
      decrease_point!

      @poll.update!(public: true)
      find_poll_members.update_all(public: true)
    end

    rescue ActiveRecord::RecordInvalid => invalid
      raise ExceptionHandler::UnprocessableEntity, invalid.record.errors.messages.values.join(", ")
  end

  def create!
    validates!
    promote!
  end
  
end