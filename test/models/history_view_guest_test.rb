# == Schema Information
#
# Table name: history_view_guests
#
#  id         :integer          not null, primary key
#  guest_id   :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class HistoryViewGuestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
