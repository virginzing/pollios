class CreatePollGroups < ActiveRecord::Migration
  def change
    create_table :poll_groups do |t|
      t.references :poll, index: true
      t.references :group, index: true

      t.timestamps
    end
  end
end
