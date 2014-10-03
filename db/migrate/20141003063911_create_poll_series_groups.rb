class CreatePollSeriesGroups < ActiveRecord::Migration
  def change
    create_table :poll_series_groups do |t|
      t.references :poll_series, index: true
      t.references :group, index: true
      t.references :member, index: true

      t.timestamps
    end
  end
end
