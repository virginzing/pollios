class RemoveUnusedColumnsFromReward < ActiveRecord::Migration
  def change
    remove_column :rewards, :photo_reward, :string
    remove_column :rewards, :order_reward, :integer
  end
end
