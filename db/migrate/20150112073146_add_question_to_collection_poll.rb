class AddQuestionToCollectionPoll < ActiveRecord::Migration
  def change
    add_column :collection_polls, :questions, :string, array: true, default: '{}'
  end
end
