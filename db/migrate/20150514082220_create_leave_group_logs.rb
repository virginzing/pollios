class CreateLeaveGroupLogs < ActiveRecord::Migration
  def change
    create_table :leave_group_logs do |t|
      t.references :member, index: true
      t.references :group, index: true
      t.datetime :leaved_at
      t.boolean :receive_invite,  default: true

      t.timestamps
    end
  end
end
