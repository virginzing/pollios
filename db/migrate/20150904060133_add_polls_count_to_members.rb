class AddPollsCountToMembers < ActiveRecord::Migration
  def change
    add_column :members, :polls_count, :integer, default: 0
  end
end
