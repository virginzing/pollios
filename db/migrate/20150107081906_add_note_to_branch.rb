class AddNoteToBranch < ActiveRecord::Migration
  def change
    add_column :branches, :note, :text
  end
end
