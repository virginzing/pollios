# == Schema Information
#
# Table name: watcheds
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  poll_notify    :boolean          default(TRUE)
#  comment_notify :boolean          default(TRUE)
#

require 'test_helper'

class WatchedTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
