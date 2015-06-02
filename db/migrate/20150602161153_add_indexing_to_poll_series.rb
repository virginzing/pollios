class AddIndexingToPollSeries < ActiveRecord::Migration
  def change
    add_index :poll_series, :campaign_id
    add_index :poll_series, :type_series
    add_index :poll_series, :type_poll
    add_index :poll_series, :public
    add_index :poll_series, :allow_comment, where: "allow_comment = false"
    add_index :poll_series, :qr_only, where: "qr_only = true"
    add_index :poll_series, :qrcode_key
    add_index :poll_series, :require_info
    add_index :poll_series, :in_group, where: "in_group = true"
    add_index :poll_series, :recurring_id
    add_index :poll_series, :feedback
  end
end
