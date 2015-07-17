class CreatePolliosApps < ActiveRecord::Migration
  def change
    create_table :pollios_apps do |t|
      t.string :name
      t.string :app_id
      t.date :expired_at
      t.integer :platform,  default: 0

      t.timestamps
    end
  end
end
