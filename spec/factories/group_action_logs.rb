# == Schema Information
#
# Table name: group_action_logs
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  taker_id   :integer
#  takee_id   :integer
#  action     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :group_action_log do

  end

end
