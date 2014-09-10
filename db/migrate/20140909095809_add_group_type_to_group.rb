class AddGroupTypeToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :group_type, :integer
    add_column :groups, :properties, :hstore
    add_hstore_index :groups, :properties
  end
end
