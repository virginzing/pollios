class DropDeviceTable < ActiveRecord::Migration
  def change
    drop_table :devices
  end
end
