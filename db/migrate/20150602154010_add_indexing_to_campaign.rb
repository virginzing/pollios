class AddIndexingToCampaign < ActiveRecord::Migration
  def change
    add_index :campaigns, :type_campaign, where: "type_campaign = 1"
    add_index :campaigns, :redeem_myself, where: "redeem_myself = true"
    add_index :campaigns, :system_campaign, where: "system_campaign = true"
  end
end
