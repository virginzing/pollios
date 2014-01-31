class AddFriendLimitToMember < ActiveRecord::Migration
  def change
    add_column :members, :friend_limit, :integer
  end
end
