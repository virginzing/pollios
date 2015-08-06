# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  poll_id      :integer
#  member_id    :integer
#  message      :text
#  created_at   :datetime
#  updated_at   :datetime
#  report_count :integer          default(0)
#  ban          :boolean          default(FALSE)
#  deleted_at   :datetime
#

require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
