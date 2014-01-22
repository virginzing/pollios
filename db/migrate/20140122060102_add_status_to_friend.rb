class AddStatusToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :status, :integer, default: 1
  end
end
