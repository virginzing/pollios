class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.references :member, index: true
      t.text :token, size: 71, null: false

      t.timestamps
    end
  end
end