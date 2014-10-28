class AddSurveyorIdToHistoryVotes < ActiveRecord::Migration
  def change
    add_column :history_votes, :surveyor_id, :integer
  end
end
