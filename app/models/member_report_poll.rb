class MemberReportPoll < ActiveRecord::Base
  belongs_to :member, touch: true
  belongs_to :poll,   touch: true
end
