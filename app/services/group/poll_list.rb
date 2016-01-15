class Group::PollList

  attr_reader :group, :viewing_member

  def initialize(group, options = {})
    @group = group

    return unless options[:viewing_member]
    @viewing_member = options[:viewing_member]
  end

  def polls
    poll_visibility
  end

  # private

  def all_poll
    Poll.joins('LEFT OUTER JOIN poll_groups on polls.id = poll_groups.poll_id')
      .where("poll_groups.group_id = #{group.id}")
  end

  def poll_visibility
    return all_poll unless viewing_member
    all_poll.viewing_by_member(viewing_member)
  end
end