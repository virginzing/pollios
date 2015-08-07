# == Schema Information
#
# Table name: group_action_logs
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  taker_id   :integer
#  takee_id   :integer
#  action     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class GroupActionLog < ActiveRecord::Base
  belongs_to :group

  def self.create_log(group, taker, takee, action)
    GroupActionLog.create!(group: group, taker_id: taker.id, takee_id: takee.id, action: action)  
  end

end
