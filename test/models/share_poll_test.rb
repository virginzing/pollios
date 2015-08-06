# == Schema Information
#
# Table name: share_polls
#
#  id              :integer          not null, primary key
#  member_id       :integer
#  poll_id         :integer
#  created_at      :datetime
#  updated_at      :datetime
#  shared_group_id :integer          default(0)
#

require 'test_helper'

class SharePollTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
