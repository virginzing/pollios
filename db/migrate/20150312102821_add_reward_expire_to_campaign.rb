class AddRewardExpireToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :reward_expire, :datetime
  end
end
