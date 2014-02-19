class AddVoteAllGuestToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :vote_all_guest, :integer, default: 0
    add_column :choices , :vote_guest, :integer,  default: 0
    add_column :poll_series, :vote_all_guest, :integer, default: 0
    
  end
end
