# == Schema Information
#
# Table name: watcheds
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  poll_notify    :boolean          default(TRUE)
#  comment_notify :boolean          default(TRUE)
#

FactoryGirl.define do
  factory :watched do
    poll_notify true
    comment_notify true
  end

end
