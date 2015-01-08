class AddSumViewAllAndSumVoteAllToCollectionPoll < ActiveRecord::Migration
  def change
    add_column :collection_polls, :sum_view_all, :integer,  default: 0
    add_column :collection_polls, :sum_vote_all, :integer,  default: 0
  end
end
