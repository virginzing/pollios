class CreatePendingVotes < ActiveRecord::Migration
  def change
    create_table :pending_votes do |t|
      t.references :member, index: true
      t.references :poll, index: true
      t.references :choice, index: true
      t.string :pending_type
      t.integer :pending_ids, array: true

      t.timestamps
    end
  end
end
