class AddGiftLogIdToCampaignMember < ActiveRecord::Migration
  def change
    add_reference :campaign_members, :gift_log, index: true
  end
end
