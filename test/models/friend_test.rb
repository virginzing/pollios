# == Schema Information
#
# Table name: friends
#
#  id           :integer          not null, primary key
#  follower_id  :integer
#  followed_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(TRUE)
#  block        :boolean          default(FALSE)
#  mute         :boolean          default(FALSE)
#  visible_poll :boolean          default(TRUE)
#  status       :integer
#  following    :boolean          default(FALSE)
#  close_friend :boolean          default(FALSE)
#

require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
