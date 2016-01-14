class Poll::MemberList
  include Poll::Private::MemberList

  attr_reader :poll, :viewing_member

  def initialize(poll, options = {})
    @poll = poll

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]

    can_view, message = can_view?
    fail ExceptionHandler::UnprocessableEntity, message unless can_view
  end

  def voter
    voter_visibility
  end

  def anonymous
    poll.vote_all - all_voter.count
  end

  def mentionable
    can_mention, message = can_mention?
    fail ExceptionHandler::UnprocessableEntity, message unless can_mention

    mentionable_visibility
  end

  def filler_mentionable(member_ids)
    fillter_mentionable_ids = []
    mentionable_ids = mentionable.map(&:id)

    member_ids.each do |member_id|
      fillter_mentionable_ids << member_id if mentionable_ids.include?(member_id)
    end

    fillter_mentionable_ids
  end
end