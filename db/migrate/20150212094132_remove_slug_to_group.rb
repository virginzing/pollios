class RemoveSlugToGroup < ActiveRecord::Migration
  def change
    remove_index :groups, :slug
    remove_column :groups, :slug
  end
end
