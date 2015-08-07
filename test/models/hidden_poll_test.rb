# == Schema Information
#
# Table name: hidden_polls
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class HiddenPollTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
