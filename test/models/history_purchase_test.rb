# == Schema Information
#
# Table name: history_purchases
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  product_id     :string(255)
#  transaction_id :string(255)
#  purchase_date  :datetime
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class HistoryPurchaseTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
