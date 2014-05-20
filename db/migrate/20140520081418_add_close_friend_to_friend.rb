class AddCloseFriendToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :close_friend, :boolean, default: false
  end
end
