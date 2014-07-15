class AddBypassInviteToMember < ActiveRecord::Migration
  def change
    add_column :members, :bypass_invite, :boolean, default: false
  end
end
