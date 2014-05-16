class AddApnPollFriendToMember < ActiveRecord::Migration
  def change
    add_column :members, :apn_poll_friend, :boolean, default: true
  end
end
