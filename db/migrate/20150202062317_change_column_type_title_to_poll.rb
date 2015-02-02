class ChangeColumnTypeTitleToPoll < ActiveRecord::Migration
  def change
    change_column :polls, :title, :text 
  end
end
