class AddIndexingToGroup < ActiveRecord::Migration
  def change
    add_index :groups, :group_type, where: "group_type = 1"
    add_index :groups, :need_approve, where: "need_approve = false"
    add_index :groups, :system_group, where: "system_group = true"
    add_index :groups, :exclusive, where: "exclusive = true"
  end
end
