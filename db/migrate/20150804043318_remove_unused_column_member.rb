class RemoveUnusedColumnMember < ActiveRecord::Migration
  def change
    remove_column :members, :group_active, :boolean
    remove_column :members, :friend_count, :integer
    remove_column :members, :poll_public_req_at, :datetime
    remove_column :members, :poll_overall_req_at, :datetime
    remove_column :members, :apn_add_friend, :boolean
    remove_column :members, :apn_invite_group, :boolean
    remove_column :members, :apn_poll_friend, :boolean
  end
end
