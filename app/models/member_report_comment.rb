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

class MemberReportComment < ActiveRecord::Base
  belongs_to :member, touch: true
  belongs_to :poll, touch: true
  belongs_to :comment, touch: true
end
