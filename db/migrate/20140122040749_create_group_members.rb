class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.references :member, index: true
      t.references :group, index: true
      t.boolean :is_master, default: true

      t.timestamps
    end
  end
end
