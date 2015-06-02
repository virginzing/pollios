class DropCampaignGuest < ActiveRecord::Migration
  def change
    drop_table :campaign_guests
  end
end
