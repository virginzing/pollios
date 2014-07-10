class CreateHistorySubscriptions < ActiveRecord::Migration
  def change
    create_table :history_subscriptions do |t|
      t.references :member, index: true
      t.string :product_id
      t.string :transaction_id
      t.datetime :purchase_date

      t.timestamps
    end
    add_index(:history_subscriptions, :transaction_id, :unique => true)
    add_column :members, :subscription, :boolean, default: false
    add_column :members, :subscribe_last, :datetime
    add_column :members, :subscribe_expire, :datetime
  end
end
