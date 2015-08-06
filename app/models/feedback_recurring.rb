# == Schema Information
#
# Table name: feedback_recurrings
#
#  id         :integer          not null, primary key
#  company_id :integer
#  period     :time
#  status     :boolean
#  created_at :datetime
#  updated_at :datetime
#

class FeedbackRecurring < ActiveRecord::Base
  belongs_to :company

  has_many :collection_poll_series
end
