class AddQrOnlyAndRequireInfoToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :qr_only, :boolean,  default: true
    add_column :poll_series, :qrcode_key, :string
    add_column :poll_series, :require_info, :boolean, default: true
    add_column :polls, :qr_only, :boolean,  default: false
    add_column :polls, :require_info, :boolean, default: false
  end
end
