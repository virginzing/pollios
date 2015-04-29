class MemberReportComment < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll
  belongs_to :comment
end
