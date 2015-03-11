class AddGiftToCampaignMember < ActiveRecord::Migration
  def change
    add_column :campaign_members, :gift, :boolean,  default: false
  end
end
