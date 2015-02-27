class AddThumbnailTypeToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :thumbnail_type, :integer, default: 0
  end
end
