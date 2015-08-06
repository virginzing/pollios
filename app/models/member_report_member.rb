# == Schema Information
#
# Table name: member_report_members
#
#  id          :integer          not null, primary key
#  reporter_id :integer
#  reportee_id :integer
#  message     :text
#  created_at  :datetime
#  updated_at  :datetime
#

class MemberReportMember < ActiveRecord::Base

  belongs_to :reporter, class_name: 'Member'
  belongs_to :reportee, class_name: 'Member'

end
