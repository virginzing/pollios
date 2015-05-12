class NotifyLog < ActiveRecord::Base
  serialize :custom_properties, Hash

  # default_scope { where("poll_deleted = 'f' AND comment_deleted = 'f'") }

  scope :without_deleted, -> { where(deleted_at: nil) }

  self.per_page = 50

  belongs_to :recipient, class_name: 'Member'
  belongs_to :sender, class_name: 'Member'

  def self.check_update_poll_deleted(poll)
    NotifyLog.without_deleted.where("custom_properties LIKE ?", "%poll_id: #{poll.id}%").update_all(deleted_at: Time.now)
  end

  def self.check_update_cancel_request_friend_deleted(sender, recipient)
    NotifyLog.without_deleted.where("custom_properties LIKE ? AND custom_properties LIKE ?", "%type: Friend%", "%action: RequestFriend%")
              .where("sender_id = #{sender.id} AND recipient_id = #{recipient.id}").update_all(deleted_at: Time.now)
  end


end
