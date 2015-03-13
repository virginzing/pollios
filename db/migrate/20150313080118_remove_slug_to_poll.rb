class RemoveSlugToPoll < ActiveRecord::Migration
  def change
    remove_column :polls, :slug
    # remove_index :polls, :slug
  end
end
