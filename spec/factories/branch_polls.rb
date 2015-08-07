# == Schema Information
#
# Table name: branch_polls
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  branch_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :branch_poll do
    poll nil
branch nil
  end

end
