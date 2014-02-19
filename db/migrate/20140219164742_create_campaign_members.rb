class CreateCampaignMembers < ActiveRecord::Migration
  def change
    create_table :campaign_members do |t|
      t.references :campaign, index: true
      t.references :member, index: true
      t.boolean :luck
      t.string :serial_code

      t.timestamps
    end
  end
end
