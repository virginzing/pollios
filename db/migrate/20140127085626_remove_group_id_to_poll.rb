class RemoveGroupIdToPoll < ActiveRecord::Migration
  def change
    remove_column :polls, :group_id
  end
end
