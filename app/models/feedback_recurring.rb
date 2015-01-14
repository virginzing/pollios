class FeedbackRecurring < ActiveRecord::Base
  belongs_to :company

  has_many :collection_poll_series
end
