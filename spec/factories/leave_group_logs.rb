# == Schema Information
#
# Table name: leave_group_logs
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  group_id       :integer
#  leaved_at      :datetime
#  receive_invite :boolean          default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :leave_group_log do

  end

end
