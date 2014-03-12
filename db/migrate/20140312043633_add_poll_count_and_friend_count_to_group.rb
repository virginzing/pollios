class AddPollCountAndFriendCountToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :friend_count, :integer, default: 0
    add_column :groups, :poll_count, :integer,  default: 0
  end
end
