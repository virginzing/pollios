class CreateSharePolls < ActiveRecord::Migration
  def change
    create_table :share_polls do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
  end
end
