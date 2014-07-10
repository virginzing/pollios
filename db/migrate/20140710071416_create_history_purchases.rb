class CreateHistoryPurchases < ActiveRecord::Migration
  def change
    create_table :history_purchases do |t|
      t.references :member, index: true
      t.string :product_id
      t.string :transaction_id
      t.datetime :purchase_date

      t.timestamps
    end
    add_index(:history_purchases, :transaction_id, :unique => true)
    add_column :members, :point, :integer, default: 0
  end
end
