class CreateGiftLogs < ActiveRecord::Migration
  def change
    create_table :gift_logs do |t|
      t.integer :admin_id
      t.integer :campaign_id
      t.string :message
      t.text :list_member, array: true, default: []

      t.timestamps
    end
  end
end
