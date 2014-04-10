class AddKeyColorToMember < ActiveRecord::Migration
  def change
    add_column :members, :key_color, :string
  end
end
