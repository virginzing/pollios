class HistoryView < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates :poll_id, :member_id, presence: true

  validates_uniqueness_of :member_id, scope: :poll_id
end
