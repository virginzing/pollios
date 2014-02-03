class AddSeriesToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :series, :boolean, default: false
    add_reference :polls, :poll_series, index: true
  end
end
