class AddClosePollToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :close_status, :boolean, default: false
    add_index :polls, :close_status
  end
end
