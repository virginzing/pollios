class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.references :campaign, index: true
      t.string :title
      t.text :detail
      t.string :photo_reward
      t.integer :order_reward,  default: 0

      t.timestamps
    end
  end
end
