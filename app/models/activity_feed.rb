# == Schema Information
#
# Table name: activity_feeds
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  action         :string(255)
#  trackable_id   :integer
#  trackable_type :string(255)
#  group_id       :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class ActivityFeed < ActiveRecord::Base
  belongs_to :member
  belongs_to :trackable, polymorphic: true
end
