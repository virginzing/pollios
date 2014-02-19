class CreateGuests < ActiveRecord::Migration
  def change
    create_table :guests do |t|
      t.string :udid

      t.timestamps
    end
  end
end
