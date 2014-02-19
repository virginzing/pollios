class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :photo_campaign
      t.integer :used,    default: 0
      t.integer :limit,   default: 0
      t.references :member, index: true

      t.timestamps
    end
  end
end
