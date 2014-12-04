class CreateSaveForLaters < ActiveRecord::Migration
  def change
    create_table :save_for_laters do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
    add_index :save_for_laters, [:member_id, :poll_id], unique: true
  end
end
