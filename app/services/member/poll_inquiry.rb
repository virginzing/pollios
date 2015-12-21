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
    voting_info_hash
  end

  def voted_hash
    { voted: true, choice_id: cached_voting_detail.first.choice_id }
  end

  def voting_info_hash
    { voted: false, can_vote: true, message: 'test message' }
  end

  def voting_detail
    HistoryVote.member_voted_poll(member.id, poll.id).to_a
  end

  def cached_voting_detail
    Rails.cache.fetch("member/#{member.id}/voting/#{poll.id}") { voting_detail_for_poll(poll.id) }
  end
end