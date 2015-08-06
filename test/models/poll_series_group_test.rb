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

require 'test_helper'

class PollSeriesGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
