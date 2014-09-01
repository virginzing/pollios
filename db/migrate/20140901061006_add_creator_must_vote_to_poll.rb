class AddCreatorMustVoteToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :creator_must_vote, :boolean,  default: true
  end
end
