class AddCampaignIdToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :campaign_id, :integer
    add_column :poll_series, :campaign_id, :integer
  end
end
