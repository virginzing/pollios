class CreateRecurrings < ActiveRecord::Migration
  def change
    create_table :recurrings do |t|
      t.time :period
      t.integer :status
      t.references :member, index: true
      t.datetime :end_recur

      t.timestamps
    end
  end
end
