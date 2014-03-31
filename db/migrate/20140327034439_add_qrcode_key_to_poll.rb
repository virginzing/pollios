class AddQrcodeKeyToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :qrcode_key, :string
  end
end
