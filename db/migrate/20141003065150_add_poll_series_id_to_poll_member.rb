class AddPollSeriesIdToPollMember < ActiveRecord::Migration
  def change
    add_column :poll_members, :poll_series_id, :integer, default: 0
  end
end
