class AddExclusiveToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :exclusive, :boolean, default: false
  end
end
