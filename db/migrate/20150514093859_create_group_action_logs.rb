class CreateGroupActionLogs < ActiveRecord::Migration
  def change
    create_table :group_action_logs do |t|
      t.references :group, index: true
      t.integer :taker_id
      t.integer :takee_id
      t.string :action

      t.timestamps
    end
  end
end
