class AddRewardInfoColumnsToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :total, :integer
    add_column :rewards, :claimed, :integer
    add_column :rewards, :odds, :integer
    add_column :rewards, :expire_at, :datetime
    add_column :rewards, :redeem_instruction, :text
    add_column :rewards, :self_redeem, :boolean
    add_column :rewards, :options, :hstore
  end
end
