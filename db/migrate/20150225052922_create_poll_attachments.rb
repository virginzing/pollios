class CreatePollAttachments < ActiveRecord::Migration
  def change
    create_table :poll_attachments do |t|
      t.references :poll, index: true
      t.string :image
      t.integer :order

      t.timestamps
    end
  end
end
