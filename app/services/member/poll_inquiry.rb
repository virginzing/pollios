class Member::PollInquiry < Member::PollList

  attr_reader :poll

  def initialize(member, poll)
    super(member)
    @poll = poll
  end

  def voted?
    voted_all.collect { |e| e['poll_id'] }.include?(poll.id)
  end

  def bookmarked?
    bookmarks_ids.include?(poll.id)
  end

  def saved_for_later?
    saved_poll_ids.include?(poll.id)
  end

  def watching?
    watched_poll_ids.include?(poll.id)
  end

  def voting_info
    return voted_hash if cached_voting_detail.present?

    voting_allows, message = can_vote?    
    return voting_allows_hash if voting_allows
    voting_not_allowed_with_reason_hash(message)
  end

  def can_vote?
    return [false, ExceptionHandler::Message::Poll::UNDER_INSPECTION] if poll.black?
    return [false, ExceptionHandler::Message::Member::BAN] if poll.member.ban?
    return [false, ExceptionHandler::Message::Poll::OUTSIDE_GROUP] if member_outside_group_visibility?
    return [false, ExceptionHandler::Message::Poll::CLOSED] if poll.closed?
    return [false, ExceptionHandler::Message::Poll::EXPIRED] if poll.expire_date < Time.zone.now
    return [false, ExceptionHandler::Message::Poll::DELETED] if poll.deleted_at.present?
    # need one more case: member & creator not friends

    [true, nil]
  end

  def member_outside_group_visibility?
    need_group_visibility_check? && !group_ids_visible_to_member?
  end

  def need_group_visibility_check?
    !poll.public && poll.in_group
  end

  def group_ids_visible_to_member?
    in_group_ids = poll.in_group_ids.split(',').map(&:to_i)
    member_active_group_ids = Member::GroupList.new(member).active_ids

    visible_group_ids = in_group_ids & member_active_group_ids
    !visible_group_ids.empty?
  end

  def voted_hash
    { voted: true, choice_id: cached_voting_detail.first.choice_id }
  end

  def voting_allows_hash
    { voted: false, can_vote: true }
  end

  def voting_not_allowed_with_reason_hash(message)
    { voted: false, can_vote: false, reason: message }
  end

  def voting_detail
    HistoryVote.member_voted_poll(member.id, poll.id).to_a
  end

  def cached_voting_detail
    Rails.cache.fetch('member/#{member.id}/voting/#{poll.id}') { voting_detail }
  end
end