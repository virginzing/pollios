class AddPriorityToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :priority, :hstore
  end
end
