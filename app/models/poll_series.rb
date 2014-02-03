class PollSeries < ActiveRecord::Base
  belongs_to :member
  has_many :polls, dependent: :destroy
  self.per_page = 10
end
