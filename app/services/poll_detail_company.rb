class PollDetailCompany
  def initialize(group, poll, options={})
    @group = group
    @poll = poll
    @options = options
  end

  def poll_id
    @poll.id
  end

  def get_member_in_group
    @member_active ||= group_member_active_ids
  end

  def get_member_voted_poll
    @member_voted_poll ||= list_history_vote_poll.select {|e| e if e.voted_at.present? }
  end

  def get_member_not_voted_poll
    @member_not_voted_poll ||= Member.where("id IN (?)", group_member_active_ids - get_member_voted_poll.map(&:id))
  end

  def get_member_viewed_poll
    @member_viewed_poll ||= list_history_view_poll.select {|e| e if e.viewed_at.present? }
  end

  def get_member_not_viewed_poll
    @member_not_viewed_poll ||= Member.where("id IN (?)", group_member_active_ids - get_member_viewed_poll.map(&:id))
  end

  def get_member_viewed_not_vote_poll
    get_member_viewed_poll.select {|e| e unless get_member_voted_poll.map(&:id).include?(e.id) }
  end

  private

  def group_member_active
    list_member_ids_active = []
    @poll.groups.each do |group|
      list_member_ids_active << group.get_member_active.map(&:id)
    end
    list_member_ids_active
  end

  def group_member_active_ids
    group_member_active.flatten.uniq
  end
  
  def list_history_vote_poll
    Member.joins("left outer join history_votes on members.id = history_votes.member_id")
          .select("members.*, history_votes.created_at as voted_at")
          .where("history_votes.poll_id = ? AND members.id IN (?)", poll_id, group_member_active_ids)
  end

  def list_history_view_poll
    Member.joins("left outer join history_views on members.id = history_views.member_id")
          .select("members.*, history_views.created_at as viewed_at")
          .where("history_views.poll_id = ? AND members.id IN (?)", poll_id, group_member_active_ids)
  end

  
end