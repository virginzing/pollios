class MemberReportComment < ActiveRecord::Base
  belongs_to :member, touch: true
  belongs_to :poll, touch: true
  belongs_to :comment, touch: true
end
