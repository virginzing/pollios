class CreateCampaignGuests < ActiveRecord::Migration
  def change
    create_table :campaign_guests do |t|
      t.references :campaign, index: true
      t.references :guest, index: true
      t.boolean :luck
      t.string :serail_code

      t.timestamps
    end
  end
end
