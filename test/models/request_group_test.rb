# == Schema Information
#
# Table name: request_groups
#
#  id          :integer          not null, primary key
#  member_id   :integer
#  group_id    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  accepter_id :integer
#  accepted    :boolean          default(FALSE)
#

require 'test_helper'

class RequestGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
