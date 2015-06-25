class AddDeletedByIdToPollGroup < ActiveRecord::Migration
  def change
    add_column :poll_groups, :deleted_by_id, :integer
    add_index :poll_groups, :deleted_by_id
  end
end
