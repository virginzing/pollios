class AddIndexUniqToHistoryView < ActiveRecord::Migration
  def change
    add_index :history_views, [:member_id, :poll_id] , :unique => true
  end
end
