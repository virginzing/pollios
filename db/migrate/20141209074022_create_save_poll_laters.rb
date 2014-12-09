class CreateSavePollLaters < ActiveRecord::Migration
  def change
    create_table :save_poll_laters do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
  end
end
