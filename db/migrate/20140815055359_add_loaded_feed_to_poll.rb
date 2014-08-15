class AddLoadedFeedToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :loadedfeed_count, :integer, default: 0
  end
end
