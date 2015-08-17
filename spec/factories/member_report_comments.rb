# == Schema Information
#
# Table name: member_report_comments
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  comment_id     :integer
#  message        :text
#  message_preset :text
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :member_report_comment do

  end
end
