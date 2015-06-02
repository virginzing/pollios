class AddIndexingToCampaignMember < ActiveRecord::Migration
  def change
    add_index :campaign_members, :serial_code, unique: true
    add_index :campaign_members, :redeem
    add_index :campaign_members, :redeem_at
    add_index :campaign_members, :poll_id
    add_index :campaign_members, :ref_no, unique: true
    add_index :campaign_members, :gift, where: "gift = true"
    add_index :campaign_members, :reward_status, where: "reward_status = 0"
    add_index :campaign_members, :created_at
  end
end
