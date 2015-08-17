# == Schema Information
#
# Table name: group_members
#
#  id           :integer          not null, primary key
#  member_id    :integer
#  group_id     :integer
#  is_master    :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  active       :boolean          default(FALSE)
#  invite_id    :integer
#  notification :boolean          default(TRUE)
#

class GroupMember < ActiveRecord::Base
  include GroupMemberHelper
  
  belongs_to :member, touch: true
  belongs_to :group,  touch: true

  def self.have_request_group?(group, member)
    find_by(group: group, member: member, active: false).present?
  end
end
