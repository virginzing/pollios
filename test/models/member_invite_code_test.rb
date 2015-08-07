# == Schema Information
#
# Table name: member_invite_codes
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  invite_code_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class MemberInviteCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
