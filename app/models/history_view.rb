class HistoryView < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates :poll_id, :member_id, presence: true
end
