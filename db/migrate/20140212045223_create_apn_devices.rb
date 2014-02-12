class CreateApnDevices < ActiveRecord::Migration # :nodoc:
  def self.up
    create_table :apn_devices do |t|
      t.text :token, :size => 71, :null => false
      t.integer :member_id
      t.string :api_token
      t.timestamps
    end
    add_index :apn_devices, :member_id
  end

  def self.down
    drop_table :apn_devices
  end
end
