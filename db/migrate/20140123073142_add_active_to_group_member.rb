class AddActiveToGroupMember < ActiveRecord::Migration
  def change
    add_column :group_members, :active, :boolean, default: false
    add_column :group_members, :invite_id, :integer
    add_column :members, :group_active, :boolean, default: false
  end
end
