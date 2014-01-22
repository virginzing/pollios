class Friend < ActiveRecord::Base
  belongs_to :follower, class_name: "Member"
  belongs_to :followed, class_name: "Member"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
