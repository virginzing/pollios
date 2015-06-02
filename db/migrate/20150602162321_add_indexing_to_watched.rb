class AddIndexingToWatched < ActiveRecord::Migration
  def change
    add_index :watcheds, :poll_notify
    add_index :watcheds, :comment_notify
  end
end
