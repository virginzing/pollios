class AddIndexingToNotifyLog < ActiveRecord::Migration
  def change
    add_index :notify_logs, :custom_properties
  end
end
