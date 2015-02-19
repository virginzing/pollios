class CreateSuggestGroups < ActiveRecord::Migration
  def change
    create_table :suggest_groups do |t|
      t.integer :group_id

      t.timestamps
    end
  end
end
