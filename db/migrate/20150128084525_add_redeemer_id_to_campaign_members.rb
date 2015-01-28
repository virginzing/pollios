class AddRedeemerIdToCampaignMembers < ActiveRecord::Migration
  def change
    add_column :campaign_members, :redeemer_id, :integer
    add_index :campaign_members, :redeemer_id
  end
end
