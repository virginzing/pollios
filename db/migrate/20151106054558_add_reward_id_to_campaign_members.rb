class AddRewardIdToCampaignMembers < ActiveRecord::Migration
  def change
    add_column :campaign_members, :reward_id, :integer
  end
end
