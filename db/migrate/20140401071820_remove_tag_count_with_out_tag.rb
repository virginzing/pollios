class RemoveTagCountWithOutTag < ActiveRecord::Migration
  def change
    remove_column :tags, :tag_count
  end
end
