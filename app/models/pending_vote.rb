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
#

class PendingVote < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll
  belongs_to :choice

  validates :pending_type, inclusion: { in: %w(Member Group) }

  def pending_for
    { pending_type.downcase.to_sym => pending_type.constantize.find(pending_ids) }
  end
end
