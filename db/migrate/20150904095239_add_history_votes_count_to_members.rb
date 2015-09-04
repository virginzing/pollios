class AddHistoryVotesCountToMembers < ActiveRecord::Migration
  def change
    add_column :members, :history_votes_count, :integer, default: 0
  end
end
