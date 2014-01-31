class CreateHistoryVotes < ActiveRecord::Migration
  def change
    create_table :history_votes do |t|
      t.references :member, index: true
      t.references :poll, index: true
      t.integer :choice_id

      t.timestamps
    end
  end
end
