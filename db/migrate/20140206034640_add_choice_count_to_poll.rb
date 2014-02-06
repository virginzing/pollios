class AddChoiceCountToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :choice_count, :integer 
  end
end
