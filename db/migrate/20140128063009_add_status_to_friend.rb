class AddStatusToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :status, :integer
    change_column :friends, :active, :boolean, default: true
  end
end
