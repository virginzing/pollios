class Member::PollInquiry < Member::PollList
  include Member::Private::PollInquiry

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

  def cached_voting_detail
    Rails.cache.fetch("member/#{member.id}/voting/#{poll.id}") { voting_detail }
  end
end