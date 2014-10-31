class AddCoverPresetToMember < ActiveRecord::Migration
  def change
    add_column :members, :cover_preset, :integer, default: 0
  end
end
