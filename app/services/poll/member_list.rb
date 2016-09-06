class Poll::MemberList
  include Poll::Private::MemberList

  attr_reader :poll, :viewing_member, :choice, :index

  def initialize(poll, options = {})
    @poll = poll

    @index = options[:index] || 1

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]

    can_view, message = can_view?
    fail ExceptionHandler::UnprocessableEntity, message unless can_view

    return unless options[:choice_id]
    @choice = poll.choices.find_by(id: options[:choice_id])

    fail ExceptionHandler::UnprocessableEntity, "This choice don't exists in poll." unless choice
  end

  def voter
    voter_visibility
  end

  def anonymous
    return vote_as_anonymous unless choice
    vote_choice_as_anonymous
  end

  def mentionable
    can_mention, message = can_mention?
    fail ExceptionHandler::UnprocessableEntity, message unless can_mention

    mentionable_visibility
  end

  def watched
    watched_visibility
  end

  def members_by_page(list)
    list.paginate(page: index)
  end

  def next_index(list)
    list.next_page || 0
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