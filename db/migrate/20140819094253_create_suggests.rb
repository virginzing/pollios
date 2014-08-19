class CreateSuggests < ActiveRecord::Migration
  def change
    create_table :suggests do |t|
      t.references :poll_series, index: true
      t.references :member, index: true
      t.text :message

      t.timestamps
    end
  end
end
