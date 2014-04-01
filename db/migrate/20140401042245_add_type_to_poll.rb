class AddTypeToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :type_poll, :integer
  end
end
