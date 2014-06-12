class MemberInviteCode < ActiveRecord::Base
  belongs_to :member
  belongs_to :invite_code
end
