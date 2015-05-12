class AddDeletedAtToNotifyLog < ActiveRecord::Migration
  def change
    add_column :notify_logs, :deleted_at, :datetime
    remove_column :notify_logs, :poll_deleted
    remove_column :notify_logs, :comment_deleted
  end
end
