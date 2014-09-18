class AddIndexUniqToGroupMember < ActiveRecord::Migration
  def change
    add_index :group_members, [:member_id, :group_id] , :unique => true
  end
end
