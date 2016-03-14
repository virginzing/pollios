class AddReceiveNotificationToApnDevices < ActiveRecord::Migration
  def change
    add_column :apn_devices, :receive_notification, :boolean, default: true
  end
end
