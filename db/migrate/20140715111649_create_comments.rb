class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :poll, index: true
      t.references :member, index: true
      t.string :message
      t.boolean :delete_status, default: false

      t.timestamps
    end
  end
end
