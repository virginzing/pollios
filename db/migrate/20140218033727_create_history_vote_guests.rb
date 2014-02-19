class CreateHistoryVoteGuests < ActiveRecord::Migration
  def change
    create_table :history_vote_guests do |t|
      t.references :guest, index: true
      t.references :poll, index: true
      t.integer :choice_id
      t.timestamps
    end
  end
end
