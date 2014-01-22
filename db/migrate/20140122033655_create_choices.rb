class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.references :poll, index: true
      t.string :answer
      t.integer :vote, default: 0

      t.timestamps
    end
  end
end
