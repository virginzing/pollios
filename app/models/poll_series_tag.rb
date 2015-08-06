# == Schema Information
#
# Table name: poll_series_tags
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  tag_id         :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class PollSeriesTag < ActiveRecord::Base
  belongs_to :poll_series
  belongs_to :tag
end
