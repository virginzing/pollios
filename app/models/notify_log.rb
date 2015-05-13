class NotifyLog < ActiveRecord::Base
  serialize :custom_properties, Hash

  # default_scope { where("poll_deleted = 'f' AND comment_deleted = 'f'") }

  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :less_than_3_days, -> { where("#{table_name}.created_at > ?", 3.days.ago) }

  self.per_page = 20

  belongs_to :recipient, class_name: 'Member'
  belongs_to :sender, class_name: 'Member'

  def self.check_update_poll_deleted(poll)
    NotifyLog.without_deleted.where("custom_properties LIKE ?", "%poll_id: #{poll.id}%").update_all(deleted_at: Time.now)
  end

  def self.check_update_cancel_request_friend_deleted(sender, recipient)
    NotifyLog.without_deleted.where("custom_properties LIKE ? AND custom_properties LIKE ?", "%type: Friend%", "%action: RequestFriend%")
              .where("sender_id = #{sender.id} AND recipient_id = #{recipient.id}").update_all(deleted_at: Time.now)
  end

  def self.check_update_comment_deleted(comment)
    NotifyLog.without_deleted.where("custom_properties LIKE ? AND custom_properties LIKE ? AND custom_properties LIKE ?", "%type: Comment%", "%action: Comment%", "%comment_id: #{comment.id}%").update_all(deleted_at: Time.now)
  end

  def self.check_update_cancel_invite_friend_to_group_deleted(sender, recipient, group)
    NotifyLog.without_deleted.where("custom_properties LIKE ? AND custom_properties LIKE ? AND custom_properties LIKE ?", "%type: Group%", "%action: Invite%", "%group_id: #{group.id}%")
              .where("sender_id = #{sender.id} AND recipient_id = #{recipient.id}").update_all(deleted_at: Time.now)
  end

  def self.check_update_cancel_request_group_deleted(sender, group)
    NotifyLog.without_deleted.where("custom_properties LIKE ? AND custom_properties LIKE ? AND custom_properties LIKE ?", "%type: RequestGroup%", "%action: Request%", "%group_id: #{group.id}%")
              .where("sender_id = #{sender.id}").update_all(deleted_at: Time.now)
  end

end
