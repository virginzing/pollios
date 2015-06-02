class AddIndexingToPollAttachment < ActiveRecord::Migration
  def change
    add_index :poll_attachments, :order_image
  end
end
