# == Schema Information
#
# Table name: companies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  short_name       :string(255)      default("CA")
#  member_id        :integer
#  address          :string(255)
#  telephone_number :string(255)
#  max_invite_code  :integer          default(0)
#  internal_poll    :integer          default(0)
#  using_service    :string(255)      default([]), is an Array
#  company_admin    :boolean          default(FALSE)
#

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
