class AddRegisterToMember < ActiveRecord::Migration
  def change
    add_column :members, :register, :integer, default: 0
  end
end
