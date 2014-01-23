class AddActiveToGroupMember < ActiveRecord::Migration
  def change
    add_column :group_members, :active, :boolean, default: true
    add_column :group_members, :invite_id, :integer
    add_column :members, :group_active, :boolean, default: true
  end
end
