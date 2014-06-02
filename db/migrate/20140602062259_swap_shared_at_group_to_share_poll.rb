class SwapSharedAtGroupToSharePoll < ActiveRecord::Migration
  def change
    remove_column :poll_members, :shared_at_group_id, :integer, default: 0
    # remove_index :poll_members, :column => :shared_at_group_id

    add_column :share_polls, :shared_group_id, :integer, default: 0
    add_index :share_polls, :shared_group_id
    add_index :share_polls, [:member_id, :poll_id, :shared_group_id], unique: true
  end
end
