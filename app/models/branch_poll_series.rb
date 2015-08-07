# == Schema Information
#
# Table name: branch_poll_series
#
#  id             :integer          not null, primary key
#  branch_id      :integer
#  poll_series_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class BranchPollSeries < ActiveRecord::Base
  belongs_to :branch
  belongs_to :poll_series
end
