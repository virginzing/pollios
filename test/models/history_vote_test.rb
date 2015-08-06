# == Schema Information
#
# Table name: history_votes
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  choice_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  poll_series_id :integer          default(0)
#  data_analysis  :hstore
#  surveyor_id    :integer
#  show_result    :boolean          default(FALSE)
#

require 'test_helper'

class HistoryVoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
