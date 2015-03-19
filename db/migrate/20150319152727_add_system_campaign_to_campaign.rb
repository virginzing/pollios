class AddSystemCampaignToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :system_campaign, :boolean,  default: false
  end
end
