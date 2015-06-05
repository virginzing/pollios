class AddExpireStatusAndCloseStatusToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :expire_status, :boolean,  default: false
    add_column :poll_series, :close_status, :boolean,   default: false

    add_index :poll_series, :expire_status, where: "expire_status = true"
    add_index :poll_series, :close_status
  end
end
