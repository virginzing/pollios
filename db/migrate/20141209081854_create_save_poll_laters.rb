class CreateSavePollLaters < ActiveRecord::Migration
  def change
    create_table :save_poll_laters do |t|
      t.references :member, index: true
      t.references :savable, polymorphic: true, index: true

      t.timestamps
    end

    add_index :save_poll_laters, [:member_id, :savable_id], unique: true
  end
end
