class AddPollSeriesIdToHistoryVote < ActiveRecord::Migration
  def change
    add_column :history_votes, :poll_series_id, :integer, default: 0
  end
end
