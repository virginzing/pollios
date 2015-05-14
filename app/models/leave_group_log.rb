class LeaveGroupLog < ActiveRecord::Base
  belongs_to :member
  belongs_to :group


  def self.leave_group_log(member, group, params = {})
    leave_group = LeaveGroupLog.new
    leave_group.assign_attributes(params)
    leave_group.member = member
    leave_group.group = group
    leave_group.leaved_at = Time.now
    leave_group.save
  end
end
