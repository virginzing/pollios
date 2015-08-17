# == Schema Information
#
# Table name: member_invite_codes
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  invite_code_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class MemberInviteCode < ActiveRecord::Base
  belongs_to :member
  belongs_to :invite_code
end
