class GroupMember < ActiveRecord::Base
  include GroupMemberHelper
  
  belongs_to :member, touch: true
  belongs_to :group,  touch: true

  def self.have_request_group?(group, member)
    find_by(group: group, member: member, active: false).present?
  end
end
