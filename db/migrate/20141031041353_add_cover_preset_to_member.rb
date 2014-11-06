class AddCoverPresetToMember < ActiveRecord::Migration
  def change
    add_column :members, :cover_preset, :string,  default: "0"
  end
end
