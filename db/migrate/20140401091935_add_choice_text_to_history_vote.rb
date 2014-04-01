class AddChoiceTextToHistoryVote < ActiveRecord::Migration
  def change
    add_column :history_votes, :choice_text, :string
  end
end
