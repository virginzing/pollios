class AddSystemPollToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :system_poll, :boolean,  default: false
  end
end
