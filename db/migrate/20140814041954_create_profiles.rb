class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :member, index: true
      t.date :birthday
      t.integer :gender
      t.text :interests
      t.string :salary
      t.integer :province

      t.timestamps
    end
  end
end
