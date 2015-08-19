class CreateMessageLogs < ActiveRecord::Migration
  def change
    create_table :message_logs do |t|
      t.integer :admin_id
      t.string :message
      t.text :list_member, array: true, default: []
      
      t.timestamps
  end
end
end
