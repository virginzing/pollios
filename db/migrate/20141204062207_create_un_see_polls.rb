class CreateUnSeePolls < ActiveRecord::Migration
  def change
    create_table :un_see_polls do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
    add_index :un_see_polls, [:member_id, :poll_id], unique: true
  end
end
