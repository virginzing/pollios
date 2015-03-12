class AddVisualGroupToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :visual_group, :boolean,  default: false
  end
end
