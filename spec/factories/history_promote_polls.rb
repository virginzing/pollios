# == Schema Information
#
# Table name: history_promote_polls
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  poll_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :history_promote_poll do
    member nil
poll nil
  end

end
