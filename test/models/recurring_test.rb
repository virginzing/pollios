# == Schema Information
#
# Table name: recurrings
#
#  id          :integer          not null, primary key
#  period      :time
#  status      :integer
#  member_id   :integer
#  end_recur   :datetime
#  created_at  :datetime
#  updated_at  :datetime
#  description :string(255)
#  company_id  :integer
#

require 'test_helper'

class RecurringTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
