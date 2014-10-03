class PollSeriesGroup < ActiveRecord::Base
  belongs_to :poll_series
  belongs_to :group
  belongs_to :member
end
