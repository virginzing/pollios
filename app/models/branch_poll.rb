class BranchPoll < ActiveRecord::Base
  belongs_to :poll
  belongs_to :branch
end
