class AddFriendCountToMember < ActiveRecord::Migration
  def change
    add_column :members, :friend_count, :integer, default: 0
  end
end
