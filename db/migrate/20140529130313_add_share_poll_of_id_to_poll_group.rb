class AddSharePollOfIdToPollGroup < ActiveRecord::Migration
  def change
    add_column :poll_groups, :share_poll_of_id, :integer, default: 0
    add_index :poll_groups, :share_poll_of_id
  end
end
