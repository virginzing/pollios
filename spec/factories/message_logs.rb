# == Schema Information
#
# Table name: message_logs
#
#  id          :integer          not null, primary key
#  admin_id    :integer
#  message     :string(255)
#  list_member :text             default([]), is an Array
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :message_log do
    
  end

end
