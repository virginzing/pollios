class AddViewAllGuestToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :view_all_guest, :integer, default: 0
    add_column :poll_series, :view_all_guest, :integer, default: 0
  end
end
