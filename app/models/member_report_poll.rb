# == Schema Information
#
# Table name: member_report_polls
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  poll_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  message        :text
#  message_preset :string(255)
#

class MemberReportPoll < ActiveRecord::Base
  belongs_to :member, touch: true
  belongs_to :poll,   touch: true
end
