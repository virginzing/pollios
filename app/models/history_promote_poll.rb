# == Schema Information
#
# Table name: history_promote_polls
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class HistoryPromotePoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates_uniqueness_of :member_id, scope: :poll_id, message: "You've already promote this poll."

end
