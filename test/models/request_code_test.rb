# == Schema Information
#
# Table name: request_codes
#
#  id                :integer          not null, primary key
#  member_id         :integer
#  custom_properties :text
#  created_at        :datetime
#  updated_at        :datetime
#

require 'test_helper'

class RequestCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
