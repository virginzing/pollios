class PollSeries < ActiveRecord::Base
  belongs_to :member
  self.per_page = 10
end
