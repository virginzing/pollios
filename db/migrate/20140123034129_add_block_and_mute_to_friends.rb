class AddBlockAndMuteToFriends < ActiveRecord::Migration
  def change
    add_column :friends, :active, :boolean
    add_column :friends, :block, :boolean, default: false
    add_column :friends, :mute, :boolean, default: false
  end
end
