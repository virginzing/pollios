class AddNameToApnDevices < ActiveRecord::Migration
  def change
    add_column :apn_devices, :name, :string
  end
end
