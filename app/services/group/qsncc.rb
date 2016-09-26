class Group::QSNCC
  attr_reader :group, :group_poll_list

  def initialize()
    @group = Group.find(2)
  end

  def current_poll
    active_polls.order(id: :asc).paginate(page: poll_page(active_polls), per_page: 1)
  end

  def close_current_poll
    poll = current_poll.first

    return false unless can_close?(poll)

    close_poll(poll)

    poll.choices
  end

  # private

  def all_polls
    Poll.joins(:poll_groups)
      .where(poll_groups: { group_id: group.id })
      .where(poll_groups: { deleted_at: nil })
  end

  def active_polls
    all_polls.where(close_status: false)
  end

  def close_poll(poll)
    poll.update!(close_status: true)
  end

  def can_close?(poll)
    poll != nil
  end

  def poll_page(polls)
    page = polls.size
    return page == 0 ? 1 : page
  end
end
