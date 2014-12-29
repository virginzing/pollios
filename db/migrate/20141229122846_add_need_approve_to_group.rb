class AddNeedApproveToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :need_approve, :boolean, default: true
  end
end
