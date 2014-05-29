class AddSharedAtGroupIdToPollMember < ActiveRecord::Migration
  def change
    add_column :poll_members, :shared_at_group_id, :integer, default: 0
    add_index :poll_members, :shared_at_group_id
  end
end
