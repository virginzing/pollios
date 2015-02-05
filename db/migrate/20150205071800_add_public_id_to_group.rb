class AddPublicIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :public_id, :string
    add_index :groups, :public_id, :unique => true
  end
end
