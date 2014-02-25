class AddFavoriteAndShareToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :favorite_count, :integer, default: 0
    add_column :polls, :share_count, :integer, default: 0
    add_column :poll_series, :share_count, :integer, default: 0
  end
end
