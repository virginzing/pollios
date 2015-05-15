class AddDeletedAtToCampaignMember < ActiveRecord::Migration
  def change
    add_column :campaign_members, :deleted_at, :datetime
    add_index :campaign_members, :deleted_at
  end
end
