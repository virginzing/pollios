class AddPollDeletedAndCommentDeletedToNotifyLog < ActiveRecord::Migration
  def change
    add_column :notify_logs, :poll_deleted, :boolean, default: false
    add_index :notify_logs, :poll_deleted
    add_column :notify_logs, :comment_deleted, :boolean, default: false
    add_index :notify_logs, :comment_deleted
  end
end
