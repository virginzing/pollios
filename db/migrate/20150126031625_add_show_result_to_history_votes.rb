class AddShowResultToHistoryVotes < ActiveRecord::Migration
  def change
    add_column :history_votes, :show_result, :boolean,  default: false
  end
end
