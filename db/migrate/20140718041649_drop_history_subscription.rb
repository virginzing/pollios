class DropHistorySubscription < ActiveRecord::Migration
  def change
    drop_table :history_subscriptions
  end
end
