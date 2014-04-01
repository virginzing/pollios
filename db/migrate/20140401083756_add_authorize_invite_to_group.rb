class AddAuthorizeInviteToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :authorize_invite, :integer
  end
end
