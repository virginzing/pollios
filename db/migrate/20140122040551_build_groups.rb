class BuildGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.boolean :publish, default: false
      t.string :photo_group

      t.timestamps
    end
  end
end
