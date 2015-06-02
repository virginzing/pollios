class AddIndexingToPoll < ActiveRecord::Migration
  def change
    add_index :polls, :status_poll, where: "status_poll = -1"
    add_index :polls, :type_poll
    add_index :polls, :require_info, where: "require_info = true"
    add_index :polls, :allow_comment, where: "allow_comment = false"
    add_index :polls, :campaign_id
    add_index :polls, :qrcode_key
    add_index :polls, :member_type
    add_index :polls, :qr_only, where: "qr_only = true"
    add_index :polls, :in_group, where: "in_group = true"
    add_index :polls, :expire_status, where: "expire_status = true"
    add_index :polls, :order_poll
    add_index :polls, :system_poll, where: "system_poll = true"
    add_index :polls, :public
    add_index :polls, :series, where: "series = true"
    add_index :polls, :created_at
  end
end
