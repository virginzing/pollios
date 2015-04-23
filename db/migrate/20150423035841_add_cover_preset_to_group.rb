class AddCoverPresetToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :cover_preset, :string, default: "0"
  end
end
