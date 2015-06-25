class PollGroup < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :poll
  belongs_to :group
  belongs_to :member

  default_scope { with_deleted }

  scope :without_deleted, -> { where(deleted_at: nil) }

  def self.delete_some_group(poll, group_id, member)
    new_in_group_ids = (poll.in_group_ids.split(",").map(&:to_i) - group_id.split(",").map(&:to_i)).join(",")
    poll.update!(in_group_ids: new_in_group_ids)
    find_poll_group = find_by(poll: poll, group_id: group_id)
    if find_poll_group
      find_poll_group.update!(deleted_by_id: member.id)
    end
  end
  
  def self.own_deleted(member, poll)
    PollGroup.where(poll: poll).each do |pg|
      pg.update(deleted_by_id: member.id)
    end
  end
end
