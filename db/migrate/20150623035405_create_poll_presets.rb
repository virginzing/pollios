class CreatePollPresets < ActiveRecord::Migration
  def change
    create_table :poll_presets do |t|
      t.integer :preset_id,   index: true
      t.string :name
      t.integer :count,   default: 0

      t.timestamps
    end


  end
end
