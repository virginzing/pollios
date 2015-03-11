class AddRewardInfoToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :reward_info, :hstore
    add_hstore_index :campaigns, :reward_info
  end
end
