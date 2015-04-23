class AddSyncFacebookLastAtAndListFbIdToMember < ActiveRecord::Migration
  def change
    add_column :members, :sync_fb_last_at, :datetime
    add_column :members, :list_fb_id, :string, array: true, default: []
  end
end
