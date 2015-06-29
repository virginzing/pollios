class AddIndexingToGroup < ActiveRecord::Migration
  def change
    add_index :groups, :system_group, where: "system_group = true"
    add_index :groups, :exclusive, where: "exclusive = true"
  end
end
