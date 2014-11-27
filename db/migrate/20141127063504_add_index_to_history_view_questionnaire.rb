class AddIndexToHistoryViewQuestionnaire < ActiveRecord::Migration
  def change
    add_index :history_view_questionnaires, [:member_id, :poll_series_id], unique: true, name: 'by_member_and_poll_series'
  end
end
