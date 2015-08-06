class RemoveUnuseSomeColumnGroup < ActiveRecord::Migration
  def change
    remove_column :groups, :member_count, :integer
    remove_column :groups, :poll_count, :integer

    if ActiveRecord::Base.connection.column_exists?(:groups, :properties)
      remove_column :groups, :properties, :hstore
    end

  end
end
