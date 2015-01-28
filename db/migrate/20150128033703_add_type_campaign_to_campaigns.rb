class AddTypeCampaignToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :type_campaign, :integer
  end
end
