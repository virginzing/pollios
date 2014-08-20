class CreateHistoryViewQuestionnaires < ActiveRecord::Migration
  def change
    create_table :history_view_questionnaires do |t|
      t.references :member, index: true
      t.references :poll_series, index: true

      t.timestamps
    end
  end
end
