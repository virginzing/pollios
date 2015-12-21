class Member::PollInquiry < Member::PollList

  attr_reader :poll

  def initialize(member, poll)
    super(member)
    @poll = poll
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
end