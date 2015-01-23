class AddPriorityToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :priority, :integer
  end
end
