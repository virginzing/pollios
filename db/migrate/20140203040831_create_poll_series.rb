class CreatePollSeries < ActiveRecord::Migration
  def change
    create_table :poll_series do |t|
      t.references :member, index: true
      t.text :description
      t.integer :number_of_poll

      t.timestamps
    end
  end
end
