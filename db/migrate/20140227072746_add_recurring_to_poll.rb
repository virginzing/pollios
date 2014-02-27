class AddRecurringToPoll < ActiveRecord::Migration
  def change
    add_reference :polls, :recurring, index: true, default: 0
  end
end
