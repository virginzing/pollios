class MemberReportPoll < ActiveRecord::Base
  belongs_to :member
  belongs_to :poll
end
