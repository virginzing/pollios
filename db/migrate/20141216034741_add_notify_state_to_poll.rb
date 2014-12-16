class AddNotifyStateToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :notify_state, :integer, default: 0
  end
end
