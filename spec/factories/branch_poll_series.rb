# == Schema Information
#
# Table name: branch_poll_series
#
#  id             :integer          not null, primary key
#  branch_id      :integer
#  poll_series_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :branch_poll_series do
    branch nil
poll_series nil
  end

end
