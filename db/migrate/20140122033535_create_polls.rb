class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.references :member, index: true
      t.string :title
      t.boolean :public, default: false
      t.integer :vote_all, default: 0

      t.timestamps
    end
  end
end
