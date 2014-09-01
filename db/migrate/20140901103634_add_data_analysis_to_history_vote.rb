class AddDataAnalysisToHistoryVote < ActiveRecord::Migration
  def change
    add_column :history_votes, :data_analysis, :hstore
    add_hstore_index :history_votes, :data_analysis
  end
end
