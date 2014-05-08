class AddNotificationToGroupMember < ActiveRecord::Migration
  def change
    add_column :group_members, :notification, :boolean, default: true
  end
end
