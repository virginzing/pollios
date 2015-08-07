# == Schema Information
#
# Table name: group_companies
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  company_id :integer
#  created_at :datetime
#  updated_at :datetime
#  main_group :boolean          default(FALSE)
#

require 'test_helper'

class GroupCompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
