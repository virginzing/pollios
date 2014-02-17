class CreatePollSeriesTags < ActiveRecord::Migration
  def change
    create_table :poll_series_tags do |t|
      t.references :poll_series, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
