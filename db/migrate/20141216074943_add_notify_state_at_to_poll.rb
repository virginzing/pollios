class AddNotifyStateAtToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :notify_state_at, :datetime
  end
end
