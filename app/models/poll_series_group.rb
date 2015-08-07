# == Schema Information
#
# Table name: poll_series_groups
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  group_id       :integer
#  member_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class PollSeriesGroup < ActiveRecord::Base
  belongs_to :poll_series
  belongs_to :group
  belongs_to :member
end
