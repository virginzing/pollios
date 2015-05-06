class NotifyLog < ActiveRecord::Base
  serialize :custom_properties, Hash

  default_scope { where("poll_deleted = 'f' AND comment_deleted = 'f'") }

  self.per_page = 50

  belongs_to :recipient, class_name: 'Member'
  belongs_to :sender, class_name: 'Member'


  def self.check_update_delete_status(poll)
    poll_id = poll.id
    NotifyLog.where("custom_properties LIKE ?", "%poll_id: #{poll_id}%").update_all(poll_deleted: true)
  end
end
