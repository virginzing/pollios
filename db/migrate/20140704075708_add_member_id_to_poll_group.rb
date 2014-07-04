class AddMemberIdToPollGroup < ActiveRecord::Migration
  def change
    add_column :poll_groups, :member_id, :integer
    add_index :poll_groups, :member_id
  end
end
