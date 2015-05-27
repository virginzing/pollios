class PollGroup < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :poll
  belongs_to :group
  belongs_to :member

  default_scope { with_deleted }

  scope :without_deleted, -> { where(deleted_at: nil) }


  def self.delete_some_group(poll, group_id)
    new_in_group_ids = (poll.in_group_ids.split(",").map(&:to_i) - group_id.split(",").map(&:to_i)).join(",")
    poll.update!(in_group_ids: new_in_group_ids)
  end
  
end
