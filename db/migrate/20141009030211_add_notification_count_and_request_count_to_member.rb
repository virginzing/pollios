class AddNotificationCountAndRequestCountToMember < ActiveRecord::Migration
  def change
    add_column :members, :notification_count, :integer, default: 0
    add_column :members, :request_count, :integer,  default: 0
  end
end
