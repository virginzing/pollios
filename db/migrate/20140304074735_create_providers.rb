class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.string :name
      t.string :pid
      t.string :token
      t.references :member, index: true

      t.timestamps
    end
  end
end
