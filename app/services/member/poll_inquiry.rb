class Member::PollInquiry < Member::PollList
  include Member::Private::PollInquiry

  attr_reader :poll

  def initialize(member, poll)
    super(member)
    @poll = poll
  end

  def view
    can_view, message = can_view?
    fail ExceptionHandler::UnprocessableEntity, message unless can_view

    process_view
  end

  def viewed?
    HistoryView.exists?(member_id: member.id, poll_id: poll.id)
  end

  def closed?
    ids_include?(closed, poll.id)
  end

  def voted?
    member_voted_choice.present?
  end

  def pending_vote?
    ids_include?(pending_vote, poll.id)
  end

  def bookmarked?
    ids_include?(bookmarks, poll.id)
  end

  def saved_for_later?
    ids_include?(saved, poll.id)
  end

  def watching?
    watched_poll_ids.include?(poll.id)
  end

  def not_interested?
    if !poll.series
      not_interested_poll_ids.include?(poll.id)
    else
      not_interested_questionnaire_ids.include?(poll.id)
    end
  end

  def reported?
    ids_include?(reports, poll.id)
  end

  def feed_info
    return poll_in_public_hash if poll_in_public?
    return poll_in_groups_hash if poll_in_groups?

    poll_in_friend_following
  end

  def voting_info
    return voted_hash if member_voted_choice.present?

    voting_allows, message = can_vote?

    return voting_allows_hash(voting_allows, message) if voting_allows
    return voting_not_allowed_with_reason_hash(message).merge(voting_detail_creator_must_not_vote) if not_allow_your_own_vote?

    voting_not_allowed_with_reason_hash(message)
  end

  def member_voted_choice
    @member_voted_choice ||= cached_voted_choice
  end

  def cached_voted_choice
    Rails.cache.fetch("member/#{member.id}/voting/#{poll.id}") { voted_choice_for_member }
  end
end