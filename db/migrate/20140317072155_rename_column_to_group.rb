class RenameColumnToGroup < ActiveRecord::Migration
  def change
    rename_column :groups, :friend_count, :member_count
  end
end
