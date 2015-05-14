class RemoveLuckColumnAndAddRewardStatusToCampaignMember < ActiveRecord::Migration
  def change
    remove_column :campaign_members, :luck
    add_column :campaign_members, :reward_status, :integer
  end
end
