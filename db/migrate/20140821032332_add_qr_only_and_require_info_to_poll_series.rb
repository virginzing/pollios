class AddQrOnlyAndRequireInfoToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :qr_only, :boolean
    add_column :poll_series, :qrcode_key, :string
    add_column :poll_series, :require_info, :boolean
    add_column :polls, :qr_only, :boolean
    add_column :polls, :require_info, :boolean
  end
end
