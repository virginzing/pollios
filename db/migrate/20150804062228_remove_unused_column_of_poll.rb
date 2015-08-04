class RemoveUnusedColumnOfPoll < ActiveRecord::Migration
  def change
    remove_column :polls, :vote_all_guest, :integer
    remove_column :polls, :view_all_guest, :integer
    remove_column :polls, :favorite_count, :integer
    remove_column :polls, :loadedfeed_count, :integer
  end
end
