class PollSeriesTag < ActiveRecord::Base
  belongs_to :poll_series
  belongs_to :tag
end
