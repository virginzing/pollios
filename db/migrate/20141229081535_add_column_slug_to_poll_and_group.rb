class AddColumnSlugToPollAndGroup < ActiveRecord::Migration
  def change
    add_column :groups, :slug, :string

    add_column :polls, :slug, :string
    
    add_index :groups, :slug, unique: true
    add_index :polls, :slug, unique: true

  end
end
