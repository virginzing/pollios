class AddSyncFacebookToMember < ActiveRecord::Migration
  def change
    add_column :members, :sync_facebook, :boolean, default: false
  end
end
