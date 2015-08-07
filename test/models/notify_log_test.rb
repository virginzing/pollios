# == Schema Information
#
# Table name: notify_logs
#
#  id                :integer          not null, primary key
#  sender_id         :integer
#  recipient_id      :integer
#  message           :string(255)
#  custom_properties :text
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#

require 'test_helper'

class NotifyLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
