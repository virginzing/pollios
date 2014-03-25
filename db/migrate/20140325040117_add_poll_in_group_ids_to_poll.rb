class AddPollInGroupIdsToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :in_group_ids, :string
  end
end
