class RemoveNameToApnDevices < ActiveRecord::Migration
  def change
    remove_column :apn_devices, :name, :string
  end
end
