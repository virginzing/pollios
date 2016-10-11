class AddAnonymousToPendingVote < ActiveRecord::Migration
  def change
    add_column :pending_votes, :anonymous, :boolean, default: false
  end
end
