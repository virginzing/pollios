class CreateNotifyLogs < ActiveRecord::Migration
  def change
    create_table :notify_logs do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :message
      t.text :custom_properties

      t.timestamps
    end
    add_index :notify_logs, :sender_id
    add_index :notify_logs, :recipient_id
  end
end
