class AddOpenedToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :opened, :boolean,  default: false

    add_index :groups, :opened
  end
end
