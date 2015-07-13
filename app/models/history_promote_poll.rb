class HistoryPromotePoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates_uniqueness_of :member_id, scope: :poll_id, message: "You've already promote this poll."

end
