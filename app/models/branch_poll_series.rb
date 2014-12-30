class BranchPollSeries < ActiveRecord::Base
  belongs_to :branch
  belongs_to :poll_series
end
