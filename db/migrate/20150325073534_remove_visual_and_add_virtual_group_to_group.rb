class RemoveVisualAndAddVirtualGroupToGroup < ActiveRecord::Migration
  def change
    remove_column :groups, :visual_group
    add_column :groups, :virtual_group, :boolean, default: false
  end
end
