class SaveForLater < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll

  validates_presence_of :member_id
  validates_presence_of :poll_id
end
