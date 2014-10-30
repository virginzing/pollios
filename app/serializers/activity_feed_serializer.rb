class ActivityFeedSerializer < ActiveModel::Serializer
  attributes :id, :action
  has_one :member
  has_one :trackable
end
