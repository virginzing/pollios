class MemberPollFeed
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  field :member_id, type: Integer
  field :poll_created_feed, type: Array
  field :poll_voted_feed, type: Array
  field :poll_watched, type: Array
end
