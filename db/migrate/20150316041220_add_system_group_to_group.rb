class AddSystemGroupToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :system_group, :boolean,  default: false
  end
end
