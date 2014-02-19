class HistoryVoteGuest < ActiveRecord::Base
  belongs_to :guest
  belongs_to :poll
end
