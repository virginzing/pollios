class AddQuizToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :quiz, :boolean, default: false
    add_column :choices, :correct, :boolean, default: false
  end
end
