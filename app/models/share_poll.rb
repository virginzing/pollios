class SharePoll < ActiveRecord::Base
  belongs_to :member, touch: true
  belongs_to :poll
end
