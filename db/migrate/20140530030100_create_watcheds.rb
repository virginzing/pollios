class CreateWatcheds < ActiveRecord::Migration
  def change
    create_table :watcheds do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
    add_index :watcheds, [:member_id, :poll_id], unique: true
  end
end
