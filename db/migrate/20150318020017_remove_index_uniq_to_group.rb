class RemoveIndexUniqToGroup < ActiveRecord::Migration
  def change
    remove_index :groups, :public_id
    add_index :groups, :public_id
  end
end
