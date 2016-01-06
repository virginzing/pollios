class Poll::CommentList

  attr_reader :poll, :member

  def initialize(poll, member)
    @poll = poll
    @member = member
  end

  def comments
    all_comment
  end

  def cached_all_comment
    all_comment
  end

  private

  def all_comment
    poll.comments.without_ban
  end

end