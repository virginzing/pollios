class CreateRedeemers < ActiveRecord::Migration
  def change
    create_table :redeemers do |t|
      t.references :company, index: true
      t.references :member, index: true

      t.timestamps
    end
  end
end
