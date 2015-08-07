# == Schema Information
#
# Table name: invite_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  used       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#  group_id   :integer
#

require 'test_helper'

class InviteCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
