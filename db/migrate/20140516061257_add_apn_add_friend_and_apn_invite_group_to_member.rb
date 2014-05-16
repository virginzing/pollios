class AddApnAddFriendAndApnInviteGroupToMember < ActiveRecord::Migration
  def change
    add_column :members, :apn_add_friend, :boolean, default: true
    add_column :members, :apn_invite_group, :boolean, default: true
  end
end
