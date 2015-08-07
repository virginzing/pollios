# == Schema Information
#
# Table name: member_report_members
#
#  id          :integer          not null, primary key
#  reporter_id :integer
#  reportee_id :integer
#  message     :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'test_helper'

class MemberReportMemberTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
