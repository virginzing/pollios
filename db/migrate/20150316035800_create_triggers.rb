class CreateTriggers < ActiveRecord::Migration
  def change
    create_table :triggers do |t|
      t.references :triggerable, polymorphic: true, index: true
      t.hstore :data
      t.timestamps
    end
    
    add_hstore_index :triggers, :data
  end
end
