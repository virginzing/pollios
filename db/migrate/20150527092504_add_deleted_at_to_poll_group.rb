class AddDeletedAtToPollGroup < ActiveRecord::Migration
  def change
    add_column :poll_groups, :deleted_at, :datetime
    add_index :poll_groups, :deleted_at
  end
end
