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

require 'test_helper'

class PollSeriesTagTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
