class AddShowResultToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :show_result, :boolean,  default: true
  end
end
