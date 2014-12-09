class SavePollLater < ActiveRecord::Base
  belongs_to :member
  belongs_to :savable, polymorphic: true
end
