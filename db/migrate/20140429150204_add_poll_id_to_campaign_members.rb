class AddPollIdToCampaignMembers < ActiveRecord::Migration
  def change
    add_column :campaign_members, :poll_id, :integer
  end
end
