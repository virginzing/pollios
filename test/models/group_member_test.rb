# == Schema Information
#
# Table name: group_members
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  group_id     :integer
#  is_master    :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(FALSE)
#  invite_id    :integer
#  notification :boolean          default(TRUE)
#

require 'test_helper'

class GroupMemberTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
