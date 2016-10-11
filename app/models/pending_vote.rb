# == Schema Information
#
# Table name: pending_votes
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  poll_id      :integer
#  choice_id    :integer
#  pending_type :string(255)
#  pending_ids  :integer          is an Array
#  created_at   :datetime
#  updated_at   :datetime
#  anonymous    :boolean          default(FALSE)
#

class PendingVote < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll
  belongs_to :choice

  scope :pending_for, (lambda do |pending_type, pending_id|
    where(pending_type: pending_type).where('? = ANY (pending_ids)', pending_id)
  end)

  validates :pending_type, inclusion: { in: %w(Member Group) }

  def pending
    { pending_type.downcase.to_sym => pending_type.constantize.find(pending_ids) }
  end
end
