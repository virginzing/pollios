class CreatePollMembers < ActiveRecord::Migration
  def change
    create_table :poll_members do |t|
      t.references :member, index: true
      t.references :poll, index: true
      t.integer :share_poll_of_id

      t.timestamps
    end
  end
end
