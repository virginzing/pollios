# == Schema Information
#
# Table name: group_surveyors
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class GroupSurveyorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
