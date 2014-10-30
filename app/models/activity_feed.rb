class ActivityFeed < ActiveRecord::Base
  belongs_to :member
  belongs_to :trackable, polymorphic: true
end
