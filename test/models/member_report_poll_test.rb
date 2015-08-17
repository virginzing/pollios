# == Schema Information
#
# Table name: member_report_polls
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  message        :text
#  message_preset :string(255)
#

require 'test_helper'

class MemberReportPollTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
