class AddIndexingToFriend < ActiveRecord::Migration
  def change
    add_index :friends, :block, where: "block = true"
  end
end
