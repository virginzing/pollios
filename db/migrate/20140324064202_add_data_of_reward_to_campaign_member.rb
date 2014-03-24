class AddDataOfRewardToCampaignMember < ActiveRecord::Migration
  def change
    add_column :campaign_members, :redeem, :boolean, default: false
    add_column :campaign_members, :redeem_at, :datetime
  end
end
