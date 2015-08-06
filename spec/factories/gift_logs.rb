# == Schema Information
#
# Table name: gift_logs
#
#  id          :integer          not null, primary key
#  admin_id    :integer
#  campaign_id :integer
#  message     :string(255)
#  list_member :text             default([]), is an Array
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :gift_log do
    admin_id 1
campaign_id 1
message "MyString"
list_member "MyText"
  end

end
