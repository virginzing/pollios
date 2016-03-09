class Group::PollList

  attr_reader :group, :viewing_member, :index

  def initialize(group, options = {})
    @group = group

    @viewing_member = options[:viewing_member]
    @index = options[:index] || 1
  end

  def polls
    poll_visibility
  end

  def polls_by_page(list)
    list.paginate(page: index)
  end

  def next_index(_)
    polls.next_page || 0
  end

  # private

  def all_poll
    Poll.joins('LEFT OUTER JOIN poll_groups on polls.id = poll_groups.poll_id')
      .where("poll_groups.group_id = #{group.id} AND poll_groups.deleted_at IS NULL")
      .paginate(page: index)
  end

  def poll_visibility
    return all_poll unless viewing_member
    all_poll.viewing_by_member(viewing_member)
  end
end