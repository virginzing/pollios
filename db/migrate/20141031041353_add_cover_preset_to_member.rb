class AddCoverPresetToMember < ActiveRecord::Migration
  def change
    add_column :members, :cover_preset, :string
  end
end
