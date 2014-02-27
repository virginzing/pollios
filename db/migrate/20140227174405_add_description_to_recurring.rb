class AddDescriptionToRecurring < ActiveRecord::Migration
  def change
    add_column :recurrings, :description, :string
  end
end
