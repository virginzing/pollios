class AddIndexingToHistoryVote < ActiveRecord::Migration
  def change
    add_index :history_votes, :surveyor_id
    add_index :history_votes, :show_result, where: "show_result = true"
    add_index :history_votes, :poll_series_id
    add_index :history_votes, :choice_id
  end
end
