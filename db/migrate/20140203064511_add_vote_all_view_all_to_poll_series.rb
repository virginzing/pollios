class AddVoteAllViewAllToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :vote_all, :integer, default: 0
    add_column :poll_series, :view_all, :integer, default: 0
    add_column :poll_series, :expire_date, :datetime
    add_column :poll_series, :start_date, :datetime, default: Time.now
  end
end
