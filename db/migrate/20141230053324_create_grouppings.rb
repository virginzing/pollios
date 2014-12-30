class CreateGrouppings < ActiveRecord::Migration
  def change
    create_table :grouppings do |t|
      t.references :collection_poll, index: true
      t.references :groupable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
