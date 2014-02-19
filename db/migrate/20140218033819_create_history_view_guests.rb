class CreateHistoryViewGuests < ActiveRecord::Migration
  def change
    create_table :history_view_guests do |t|
      t.references :guest, index: true
      t.references :poll, index: true

      t.timestamps
    end
  end
end
