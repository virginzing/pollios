class AddCommentNotifyStateAndCommentNotifyStateAtToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :comment_notify_state, :integer, default: 0
    add_column :polls, :comment_notify_state_at, :datetime
  end
end
