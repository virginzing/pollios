class AddInfoToApnDevices < ActiveRecord::Migration
  def change
    add_column :apn_devices, :model, :hstore, default: { name: nil, type: nil, version: nil }
    add_column :apn_devices, :os, :hstore, default: { name: nil, version: nil }
  end
end
