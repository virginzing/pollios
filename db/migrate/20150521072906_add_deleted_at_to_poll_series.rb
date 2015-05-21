class AddDeletedAtToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :deleted_at, :datetime
    add_index :poll_series, :deleted_at
  end
end
