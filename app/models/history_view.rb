# == Schema Information
#
# Table name: history_views
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class HistoryView < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates :poll_id, :member_id, presence: true

  validates_uniqueness_of :member_id, scope: :poll_id
end
