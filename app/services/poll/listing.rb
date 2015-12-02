class Poll::Listing

  attr_reader :poll

  def initialize(poll, options = {})
    @poll = poll
    @options = options
  end

  def is_visible_to_member_with_error(member)
    return false, ExceptionHandler::Message::Poll::UNDER_INSPECTION if poll.black?
    return false, ExceptionHandler::Message::Member::BAN if poll.member.ban?
    return false, ExceptionHandler::Message::Poll::OUTSIDE_GROUP if needs_group_visibility_check? && group_ids_visible_to_member(member).size == 0

    [true, nil]
  end

  def in_group_ids
    poll.in_group_ids.split(',').map(&:to_i)
  end

  def group_ids_visible_to_member(member)
    member_active_group_ids = Member::GroupList.new(member).active_ids
    in_group_ids & member_active_group_ids
  end

  private

  def needs_group_visibility_check?
    poll.in_group && !poll.public
  end

end