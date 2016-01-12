class Poll::MemberList

  attr_reader :poll

  def initialize(poll)
    @poll = poll
  end

  def voted
    all_voted
  end

  def anonymous
    poll.vote_all - voted.count
  end

  def mentionable
    all_mentionale
  end

  private

  def all_voted
    Member.joins('LEFT OUTER JOIN history_votes ON members.id = history_votes.member_id')
      .where("history_votes.poll_id = #{poll.id}")
      .where("history_votes.show_result = 't'")
      .order('LOWER(members.fullname)')
  end
end