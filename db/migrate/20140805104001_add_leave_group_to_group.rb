class AddLeaveGroupToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :leave_group, :boolean, default: true
  end
end
