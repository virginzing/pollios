class RemoveUnusedColumnOfPollSeries < ActiveRecord::Migration
  def change
    remove_column :poll_series, :vote_all_guest, :integer
    remove_column :poll_series, :view_all_guest, :integer
  end
end
