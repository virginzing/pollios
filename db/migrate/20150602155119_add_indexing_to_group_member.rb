class AddIndexingToGroupMember < ActiveRecord::Migration
  def change
    add_index :group_members, :is_master, where: "is_master = true"
    add_index :group_members, :active
    add_index :group_members, :invite_id
  end
end
