class Group::QSNCC
  attr_reader :group, :public_id

  def initialize(public_id)
    @public_id ||= public_id
    @group ||= Group.where(public_id: @public_id).first

    fail ActionController::RoutingError, 'The group cannot be found.' if @group.nil?
  end

  def poll_by_index(index)
    poll = all_polls
      .order(id: :asc)
      .paginate(page: index, per_page: 1)
      .first

    fail ActionController::RoutingError, 'The group cannot be found.' if poll.nil?

    poll
  end

  def current_poll
    active_polls
      .order(id: :asc)
      .paginate(page: poll_page(active_polls), per_page: 1)
      .first
  end

  def close_current_poll
    poll = current_poll

    return false unless can_close?(poll)

    close(poll)
  end

  def recently_closed_poll
    closed_polls.limit(1).first
  end

  def has_polls?
    all_polls.size != 0
  end

  def all_polls_already_close?
    active_polls.size == 0
  end

  def no_closed_poll?
    closed_polls.size == 0
  end

  def close_poll_url
    '/qsncc/close?public_id=' + @public_id
  end

  def next_poll_url
    '/qsncc?public_id=' + @public_id
  end

  private

  def all_polls
    Poll.joins(:poll_groups)
      .where(poll_groups: { group_id: group.id })
      .where(poll_groups: { deleted_at: nil })
  end

  def active_polls
    all_polls.where(close_status: false)
  end

  def closed_polls
    all_polls.where(close_status: true)
  end

  def can_close?(poll)
    !all_polls_already_close?
  end

  def close(poll)
    poll.update!(close_status: true)
  end

  def poll_page(polls)
    page = polls.size
    return page == 0 ? 1 : page
  end
end
