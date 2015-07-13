class AddNotificationToMember < ActiveRecord::Migration
  def change
    add_column :members, :notification, :hstore, default: '', null: false
    add_hstore_index :members, :notification
  end
end
