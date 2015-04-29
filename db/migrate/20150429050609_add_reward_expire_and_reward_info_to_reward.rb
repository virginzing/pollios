class AddRewardExpireAndRewardInfoToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :reward_expire, :datetime
  end
end
