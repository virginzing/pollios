class MemberReportMember < ActiveRecord::Base

  belongs_to :reporter, class_name: 'Member'
  belongs_to :reportee, class_name: 'Member'

end
