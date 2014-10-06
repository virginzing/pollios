class AddOrderPollToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :order_poll, :integer, default: 1
  end
end
