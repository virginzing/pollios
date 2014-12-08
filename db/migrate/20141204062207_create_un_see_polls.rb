class CreateUnSeePolls < ActiveRecord::Migration
  def change
    create_table :un_see_polls do |t|
      t.references :member, index: true
      t.belongs_to :unseeable, polymorphic: true, index: true

      t.timestamps
    end

    add_index :un_see_polls, [:member_id, :unseeable_id], unique: true
  end
end
