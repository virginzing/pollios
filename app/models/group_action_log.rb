class GroupActionLog < ActiveRecord::Base
  belongs_to :group

  def self.create_log(group, taker, takee, action)
    GroupActionLog.create!(group: group, taker_id: taker.id, takee_id: takee.id, action: action)  
  end

end
