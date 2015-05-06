class AddDeletedAtToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :deleted_at, :datetime
    add_index :polls, :deleted_at
  end
end
