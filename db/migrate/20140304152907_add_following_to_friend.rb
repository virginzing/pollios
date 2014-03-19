class AddFollowingToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :following, :boolean, default: false
  end
end
