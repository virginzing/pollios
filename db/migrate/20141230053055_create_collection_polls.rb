class CreateCollectionPolls < ActiveRecord::Migration
  def change
    create_table :collection_polls do |t|
      t.string :title
      t.references :company, index: true

      t.timestamps
    end
  end
end
