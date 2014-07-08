class AddPollNotifyAndCommentNotifyToWatched < ActiveRecord::Migration
  def change
    add_column :watcheds, :poll_notify, :boolean, default: true
    add_column :watcheds, :comment_notify, :boolean,  default: true
  end
end
