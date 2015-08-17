# == Schema Information
#
# Table name: suggests
#
#  id             :integer          not null, primary key
#  poll_series_id :integer
#  member_id      :integer
#  message        :text
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class SuggestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
