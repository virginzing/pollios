# == Schema Information
#
# Table name: choices
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  answer     :string(255)
#  vote       :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#  vote_guest :integer          default(0)
#  correct    :boolean          default(FALSE)
#

require 'test_helper'

class ChoiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
