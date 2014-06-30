class RenameColumnAndAddAnonemousNotificationToMember < ActiveRecord::Migration
  def change

    add_column :members, :anonymous_public, :boolean, default: false
    add_column :members, :anonymous_friend_following, :boolean, default: false
    add_column :members, :anonymous_group, :boolean, default: false
    rename_column :members, :sentai_name, :fullname

  end
end
