class AddIndexingToComment < ActiveRecord::Migration
  def change
    add_index :comments, :created_at
    add_index :comments, :ban, where: "ban = true"
  end
end
