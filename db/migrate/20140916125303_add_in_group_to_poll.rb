class AddInGroupToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :in_group, :boolean, default: false
  end
end
