class AddAdminPostOnlyToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :admin_post_only, :boolean, default: false
  end
end
