class AddRefNoToCampaignMembers < ActiveRecord::Migration
  def change
    add_column :campaign_members, :ref_no, :string
  end
end
