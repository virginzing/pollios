# == Schema Information
#
# Table name: notify_logs
#
#  id                :integer          not null, primary key
#  sender_id         :integer
#  recipient_id      :integer
#  message           :string(255)
#  custom_properties :text
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#

# TODO : rename -> UpdateLog
class NotifyLog < ActiveRecord::Base
  serialize :custom_properties, Hash

  # default_scope { where("poll_deleted = 'f' AND comment_deleted = 'f'") }

  scope :without_deleted, -> { where(deleted_at: nil) }
  scope :less_than_3_days, -> { where("#{table_name}.created_at > ?", 3.days.ago) }
  scope :next_notifications, -> (next_notification) { where('id < ?', next_notification) }

  self.per_page = 40

  belongs_to :recipient, class_name: 'Member'
  belongs_to :sender, class_name: 'Member'

  def self.update_deleted_poll(poll)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ?', "%poll_id: #{poll.id}%")
      .update_all(deleted_at: Time.now)
  end

  def self.update_deleted_poll_for_member(poll, member)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ?', "%poll_id: #{poll.id}%")
      .where("recipient_id = #{member.id}")
      .update_all(deleted_at: Time.now)
  end

  def self.update_cancel_friend_request(sender, recipient)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ? AND custom_properties LIKE ?', '%type: Friend%', '%action: RequestFriend%')
      .where("sender_id = #{sender.id} AND recipient_id = #{recipient.id}")
      .update_all(deleted_at: Time.now)
  end

  def self.update_deleted_comment(comment)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ? AND custom_properties LIKE ?', '%type: Comment%', "%comment_id: #{comment.id}%")
      .update_all(deleted_at: Time.now)
  end

  def self.update_cancel_invitation_to_group(sender, recipient, group)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ? AND custom_properties LIKE ? AND custom_properties LIKE ?' \
        , '%type: Group%', '%action: Invite%', "%group_id: #{group.id}%")
      .where("sender_id = #{sender.id} AND recipient_id = #{recipient.id}")
      .update_all(deleted_at: Time.now)
  end

  def self.update_cancel_request_to_join_group(sender, group)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ? AND custom_properties LIKE ? AND custom_properties LIKE ?' \
        , '%type: RequestGroup%', '%action: Request%', "%group_id: #{group.id}%")
      .where("sender_id = #{sender.id}")
      .update_all(deleted_at: Time.now)
  end

  # TODO : remove methods below after changed this model to UpdateLog & implement new structure 

  def self.update_deleted_poll_in_group(poll, group)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ? AND custom_properties LIKE ? AND custom_properties LIKE ?' \
        , '%type: Poll%', "%poll_id: #{poll.id}%", "%group_id: #{group.id}%")
      .update_all(deleted_at: Time.now)
  end

  def self.update_deleted_feedback(poll_series)
    NotifyLog.without_deleted
      .where('custom_properties LIKE ? AND custom_properties LIKE ?', "%poll_id: #{poll_series.id}%", '%series: true%')
      .update_all(deleted_at: Time.now)
  end

  def self.update_changed_member_name(member, new_name, old_name)
    NotifyLog.without_deleted
      .where("sender_id = #{member.id} AND message LIKE ?", "%#{old_name}%").all.each do |notify_log|
      begin
        current_message = notify_log.message
        change_message = current_message.sub(/#{old_name}/, new_name)
        notify_log.update!(message: change_message)
      rescue
      end
    end
  end
end
